// Local includes
#include "Material.h"
#include "Shader.h"
#include "Texture.h"
#include "Context.h"
// GLM includes
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
// OPENGL includes
#include <GL/glew.h>
#include <GL/glut.h>

Material::~Material() {
	if (m_program != 0) {
		glDeleteProgram(m_program);
	}
}

void Material::init() {
	// TODO : Change shader by your
	m_program_mesh = load_shaders("shaders/unlit/vertex.glsl", "shaders/unlit/fragment.glsl");
    m_program_skyBox = load_shaders("shaders/unlit/vertexSky.glsl", "shaders/unlit/fragmentSky.glsl");
	check();
	// TODO : set initial parameters
	m_color = {1.0, 1.0, 1.0, 1.0};

    //Si on utilise la boombox pour import les textures
    //m_texture = loadTexture2DFromFilePath("data/Boombox/BoomBox_baseColor.png");
    //m_normalMap = loadTexture2DFromFilePath("data/Boombox/BoomBox_normal.png");
    //m_metallic = loadTexture2DFromFilePath("data/Boombox/BoomBox_occlusionRoughnessMetallic.png");

    light_position = {2, -2, 2};

// Construction de la skybox
    float skyboxVertices[] = {
            -20.0f,  20.0f, -20.0f,
            -20.0f, -20.0f, -20.0f,
            20.0f, -20.0f, -20.0f,
            20.0f, -20.0f, -20.0f,
            20.0f,  20.0f, -20.0f,
            -20.0f,  20.0f, -20.0f,

            -20.0f, -20.0f,  20.0f,
            -20.0f, -20.0f, -20.0f,
            -20.0f,  20.0f, -20.0f,
            -20.0f,  20.0f, -20.0f,
            -20.0f,  20.0f,  20.0f,
            -20.0f, -20.0f,  20.0f,

            20.0f, -20.0f, -20.0f,
            20.0f, -20.0f,  20.0f,
            20.0f,  20.0f,  20.0f,
            20.0f,  20.0f,  20.0f,
            20.0f,  20.0f, -20.0f,
            20.0f, -20.0f, -20.0f,

            -20.0f, -20.0f,  20.0f,
            -20.0f,  20.0f,  20.0f,
            20.0f,  20.0f,  20.0f,
            20.0f,  20.0f,  20.0f,
            20.0f, -20.0f,  20.0f,
            -20.0f, -20.0f,  20.0f,

            -20.0f,  20.0f, -20.0f,
            20.0f,  20.0f, -20.0f,
            20.0f,  20.0f,  20.0f,
            20.0f,  20.0f,  20.0f,
            -20.0f,  20.0f,  20.0f,
            -20.0f,  20.0f, -20.0f,

            -20.0f, -20.0f, -20.0f,
            -20.0f, -20.0f,  20.0f,
            20.0f, -20.0f, -20.0f,
            20.0f, -20.0f, -20.0f,
            -20.0f, -20.0f,  20.0f,
            20.0f, -20.0f,  20.0f
    };

    // VBO_Skybox
    glGenBuffers(1, &VBO_Skybox);
    glGenVertexArrays(1, &VAO_Skybox);

    glBindBuffer(GL_ARRAY_BUFFER, VBO_Skybox);
    glBindVertexArray(VAO_Skybox);

    glBufferData(GL_ARRAY_BUFFER, sizeof(skyboxVertices), skyboxVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), (void*)0);

    // Load Texture Skybox
    std::vector<std::string> skyboxTex= {
            "data/skybox/right.jpg",
            "data/skybox/left.jpg",
            "data/skybox/top.jpg",
            "data/skybox/bottom.jpg",
            "data/skybox/front.jpg",
            "data/skybox/back.jpg"
    };
    m_texture_sky = loadCubeMap(skyboxTex);
}

void Material::clear() {
	// nothing to clear
	// TODO: Add the texture or buffer you want to destroy for your material
}

void Material::bind(int objId) {

    check();
    if(objId == 0){
        m_program = m_program_skyBox;
    } else {
        m_program = m_program_mesh;
    }
    glUseProgram(m_program);
    internalBind(objId);
}

void Material::internalBind(int objId) {
	// bind parameters

    if(objId == 0)
    {
        glDepthFunc(GL_LEQUAL);
        glBindVertexArray(VAO_Skybox);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_CUBE_MAP, m_texture_sky);
        glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);
        glDepthFunc(GL_LESS);
    }

    else if(objId == 1)
    {
        GLint color = getUniform("color");
        glUniform4fv(color, 1, glm::value_ptr(m_color));
        if (m_texture != -1) {
            glUniform1i(getUniform("colorTexture"), 0);
            glActiveTexture(GL_TEXTURE0 + 0);
            glBindTexture(GL_TEXTURE_2D, m_texture);
        }
        if (m_normalMap != -1) {
            glUniform1i(getUniform("normalTexture"), 1);
            glActiveTexture(GL_TEXTURE0 + 1);
            glBindTexture(GL_TEXTURE_2D, m_normalMap);
        }
        if (m_metallic != -1) {
            glUniform1i(getUniform("metalTexture"), 2);
            glActiveTexture(GL_TEXTURE0 + 2);
            glBindTexture(GL_TEXTURE_2D, m_metallic);
        }
    }



    glUniform3fv(getUniform("viewPos"), 1, glm::value_ptr(Context::camera.position));
    glUniform3fv(getUniform("lightPos"), 1.0f , glm::value_ptr(light_position));

}

void Material::setMatrices(glm::mat4& projectionMatrix, glm::mat4& viewMatrix, glm::mat4& modelMatrix)
{
	check();
	glUniformMatrix4fv(getUniform("projection"), 1, false, glm::value_ptr(projectionMatrix));
	glUniformMatrix4fv(getUniform("view"), 1, false, glm::value_ptr(viewMatrix));
	glUniformMatrix4fv(getUniform("model"), 1, false, glm::value_ptr(modelMatrix));
}

GLint Material::getAttribute(const std::string& in_attributeName) {
	check();
	return glGetAttribLocation(m_program, in_attributeName.c_str());
}

GLint Material::getUniform(const std::string& in_uniformName) {
	check();
	return glGetUniformLocation(m_program, in_uniformName.c_str());
}
