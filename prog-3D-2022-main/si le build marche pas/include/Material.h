#ifndef MATERIAL_H_DEFINED
#define MATERIAL_H_DEFINED
#include <GL/glew.h>
#include <GL/glut.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include <string>
#include <stdexcept>
#include "Vec3.h"

struct Material {
    GLuint VBO_Skybox;
    GLuint VAO_Skybox;

	// Shader program
	GLuint m_program;
    GLuint m_program_mesh;
    GLuint m_program_skyBox;

	// Material parameters
	glm::vec4 m_color;
	GLint m_texture;
    GLint m_normalMap;
    GLint m_metallic;

    GLuint m_texture_sky;

    // Lights

    glm::vec3 light_position;

	inline void check() {
		if (m_program_mesh == 0) {
			throw std::runtime_error("Shader program not initialized");
		}
        if (m_program_skyBox == 0) {
            std::cout << "Sky shader not initialized" << std::endl;
        }
	}

	Material(): m_program(0) {

	}

	virtual ~Material();

	virtual void init();

	virtual void clear();

	void bind(int objId);

	virtual void internalBind(int objId);

	void setMatrices(glm::mat4& projectionMatrix, glm::mat4& viewMatrix, glm::mat4& modelMatrix);

	GLint getAttribute(const std::string& in_attributeName);

	GLint getUniform(const std::string& in_uniformName);
};

#endif
