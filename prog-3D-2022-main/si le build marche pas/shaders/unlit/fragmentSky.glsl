#version 330 core

in vec3 textureCoord;

uniform samplerCube skybox;
uniform vec3 viewPos;

out vec4 FragColor;


void main() {

    FragColor = texture(skybox, textureCoord);
}
