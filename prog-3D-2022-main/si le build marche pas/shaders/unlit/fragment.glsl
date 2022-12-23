#version 330 core

in vec3 o_position;
in vec3 o_normal;
in vec2 o_uv0;
in vec3 fragPos;
in vec3 tangentSpace_lightPos;
in vec3 tangentSpace_viewPos;
in vec3 tangentSpace_fragPos;
in mat3 TBN;

uniform vec3 color;
uniform sampler2D colorTexture;
uniform sampler2D normalTexture;
uniform sampler2D metalTexture;
uniform samplerCube skybox;
uniform vec3 lightPos;
uniform vec3 viewPos;

/*uniform vec3 albedo;
uniform float metallic;
uniform float roughness;
uniform float ao;*/

out vec4 FragColor;

float PI = 3.141592;

    // Fonction necessaire pour le calcul du PBR
    vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return num / denom;
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}

void main() {

    //vec3 colorFromTexture = texture(colorTexture, o_uv0).rgb;
    vec3 colorFromTexture = vec3(1.,1.,1.);
    vec3 normalFromTexture = texture(normalTexture, o_uv0).rgb;
    normalFromTexture = normalize(normalFromTexture*2.0 - 1.0);
    normalFromTexture = vec3(normalFromTexture.x, -normalFromTexture.y, normalFromTexture.z);

    float metalFromTexture = texture(metalTexture, o_uv0).r + texture(metalTexture, o_uv0).g + texture(metalTexture, o_uv0).b;
    metalFromTexture /= 1.5;

    vec3 lightColor = vec3(1,1,1);

    vec3 lp = lightPos;
    vec3 lp2 = vec3(-lp.x, lp.y, lp.z);
    vec3 lp3 = vec3(0,1,1);

    vec3 lpTab[3] = vec3[3](
        vec3(3,-3,3),
        vec3(-3,3,0),
        vec3(0,8,5)
    );

    vec3 vp = viewPos;
    vec3 N = o_normal;
    //vec3 N = normalFromTexture; // A utiliser si on utilise une normalmap
    vec3 lightDir = normalize(lp - fragPos);
    vec3 viewDir = normalize(vp - fragPos);
    vec3 reflectDir = reflect(-lightDir, N);



  // Phong
    vec3 ambient = 0.1 * colorFromTexture;
    vec3 diffuse = max(dot(N, lightDir), 0.0) * colorFromTexture;
    vec3 specular = lightColor * pow(max(dot(viewDir, reflectDir), 0), 50) * 0.2;
    vec4 classicPhongColor = vec4(ambient + diffuse + specular, 1.0);


    // Reflexion par rapport a la camera 
    vec3 camToFrag = normalize(fragPos - viewPos);
    vec3 reflectedView = reflect(camToFrag, N);
    vec4 reflectionColor = vec4(texture(skybox, reflectedView).rgb, 1.0);

    //Physically Based Rendering
    //Attribut utile 
    vec3 albedo = colorFromTexture;
    float metallic = 0.5;
    float roughness = 0.5;
    float ao = 10;
    vec3 resultPBR = vec3(0.0);

    vec3 F0 = vec3(0.1);
    F0      = mix(F0, albedo, metallic);
    for(int i = 0; i < lpTab.length(); i++){

        vec3 lightDir2 = normalize(lpTab[i] - fragPos);
        //Lehafway prennant en compte l'angle de vue 
        vec3 Halfway = normalize(viewDir + lightDir2);

        //La radiance et l'attenuation
        float distanceFromL = length(lightDir);
        float attenuation = 1.0/(distanceFromL*distanceFromL);
        vec3 radiance = lightColor * attenuation;
        //Utilisation des fonctions écrite avant le main pour compute
        float NDF = DistributionGGX(N, Halfway, roughness);
        float G   = GeometrySmith(N, viewDir, lightDir2, roughness);
        vec3 F    = fresnelSchlick(max(dot(Halfway, viewDir), 0.0), F0);
        //Les reflets
        vec3 kS = F;
        vec3 kD = vec3(1.0) - kS;
        kD *= 1.0 - metallic;
        //Utilisation de tout nos éléments
        vec3 numerator    = NDF * G * F;
        float denominator = 4.0 * max(dot(N, viewDir), 0.0) * max(dot(N, lightDir2), 0.0) + 0.0001;
        vec3 specularPBR     = numerator / denominator;
        float NdotL = max(dot(N, lightDir2), 0.0);
        //Resultat final
        resultPBR += (kD * albedo / PI + specularPBR) * radiance * NdotL;
    }

    vec3 ambientPBR = vec3(0.03) * albedo * ao;
    vec3 colorPBR = ambientPBR + resultPBR;
    vec4 pbrColor = vec4(resultPBR + ambientPBR, 1.0);



    FragColor = pbrColor;
    //FragColor = reflectionColor;
    //FragColor = classicPhongColor;
    //FragColor = vec4(vec3(1,1,1), 1.0); //Pour debug
}