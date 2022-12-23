#version 330 core

layout(location = 0) in vec3 position;

uniform mat4 view;
uniform mat4 projection;
uniform vec3 viewPos;

out vec3 textureCoord;


void main() {

    textureCoord = position;
    vec4 pos = projection * view * vec4(position, 1.0);
    gl_Position = pos.xyww;
}
