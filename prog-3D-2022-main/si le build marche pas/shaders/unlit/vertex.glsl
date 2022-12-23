#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec3 tangent;
layout(location = 3) in vec2 uv0;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform vec3 lightPos;
uniform vec3 viewPos;


out vec3 o_position;
out vec3 o_normal;
out vec2 o_uv0;
out vec3 fragPos;
out vec3 tangentSpace_lightPos;
out vec3 tangentSpace_viewPos;
out vec3 tangentSpace_fragPos;
out mat3 TBN;



void main() {

  // on défini la base avec un plan tangent triangle pour appliquer correctement la normalMap
  mat3 normalMatrix = transpose(inverse(mat3(model)));

  //vec3 T = normalize(vec3(model * vec4(tangent, 0.0)));
  //vec3 N = normalize(vec3(model * vec4(normal, 0.0)));

  vec3 T = normalize(normalMatrix*tangent);
  vec3 N = normalize(normalMatrix*normal);

  T = normalize(T - dot(T,N) * N);
  vec3 B = cross(N, T);

  TBN = transpose(mat3(T,B,N));


  fragPos = vec3(model * vec4(position, 1.0));
  gl_Position = projection * view * model * vec4(position, 1.0);

  // ------------- out -------------

  o_normal = normal;
  o_uv0 = vec2(uv0.x, -uv0.y);

  tangentSpace_lightPos = TBN * lightPos;
  tangentSpace_viewPos = TBN * viewPos;
  tangentSpace_fragPos = TBN * fragPos;
}
