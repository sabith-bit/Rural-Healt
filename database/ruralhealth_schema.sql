-- =====================================================
-- RuralHealth - Esquema de base de datos (MySQL 8)
-- Proyecto de aula - Ingeniería de Software - UAJS
-- =====================================================

CREATE DATABASE IF NOT EXISTS ruralhealth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ruralhealth;

-- ---------- Seguridad: roles y usuarios ----------
CREATE TABLE rol (
  id_rol      TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre      VARCHAR(30) NOT NULL UNIQUE   -- ADMIN, MEDICO, ENFERMERIA, ADMISION
);

CREATE TABLE usuario (
  id_usuario  INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre      VARCHAR(100) NOT NULL,
  correo      VARCHAR(120) NOT NULL UNIQUE,
  clave_hash  VARCHAR(100) NOT NULL,        -- BCrypt, nunca texto plano
  id_rol      TINYINT UNSIGNED NOT NULL,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

-- ---------- Pacientes ----------
CREATE TABLE paciente (
  id_paciente      INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tipo_documento   ENUM('CC','TI','RC','CE','OTRO') NOT NULL,
  documento        VARCHAR(20) NOT NULL,
  nombres          VARCHAR(80) NOT NULL,
  apellidos        VARCHAR(80) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  sexo             ENUM('F','M','OTRO') NOT NULL,
  telefono         VARCHAR(20),
  vereda_direccion VARCHAR(150),
  antecedentes     TEXT,
  creado_en        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_paciente_doc (tipo_documento, documento)
);

-- ---------- Atención ----------
CREATE TABLE atencion (
  id_atencion   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_paciente   INT UNSIGNED NOT NULL,
  id_usuario_registra INT UNSIGNED NOT NULL,
  motivo        VARCHAR(255) NOT NULL,
  estado        ENUM('ABIERTA','EN_TRIAJE','EN_CONSULTA','CERRADA') NOT NULL DEFAULT 'ABIERTA',
  prioridad     ENUM('ROJA','NARANJA','AMARILLA','VERDE') NULL,
  fecha_ingreso DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_cierre  DATETIME NULL,
  FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
  FOREIGN KEY (id_usuario_registra) REFERENCES usuario(id_usuario),
  INDEX idx_atencion_estado (estado, prioridad)
);

CREATE TABLE signos_vitales (
  id_signos        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion      INT UNSIGNED NOT NULL,
  temperatura      DECIMAL(4,1),            -- °C
  frecuencia_cardiaca SMALLINT UNSIGNED,    -- lpm
  frecuencia_respiratoria SMALLINT UNSIGNED,-- rpm
  presion_sistolica   SMALLINT UNSIGNED,    -- mmHg
  presion_diastolica  SMALLINT UNSIGNED,    -- mmHg
  saturacion_o2    TINYINT UNSIGNED,        -- %
  peso_kg          DECIMAL(5,2),
  registrado_por   INT UNSIGNED NOT NULL,
  registrado_en    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (registrado_por) REFERENCES usuario(id_usuario)
);

CREATE TABLE sintoma (
  id_sintoma  SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  nombre      VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE atencion_sintoma (
  id_atencion INT UNSIGNED NOT NULL,
  id_sintoma  SMALLINT UNSIGNED NOT NULL,
  observacion VARCHAR(150),
  PRIMARY KEY (id_atencion, id_sintoma),
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (id_sintoma) REFERENCES sintoma(id_sintoma)
);

-- ---------- Triaje por reglas transparentes ----------
CREATE TABLE regla_triaje (
  id_regla     INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  descripcion  VARCHAR(200) NOT NULL,
  parametro    ENUM('TEMPERATURA','FRECUENCIA_CARDIACA','FRECUENCIA_RESPIRATORIA',
                    'PRESION_SISTOLICA','SATURACION_O2','SINTOMA') NOT NULL,
  operador     ENUM('<','<=','>','>=','=') NOT NULL,
  valor_umbral DECIMAL(6,2) NULL,           -- NULL cuando parametro = SINTOMA
  id_sintoma   SMALLINT UNSIGNED NULL,      -- solo cuando parametro = SINTOMA
  prioridad    ENUM('ROJA','NARANJA','AMARILLA','VERDE') NOT NULL,
  activa       BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (id_sintoma) REFERENCES sintoma(id_sintoma)
);

CREATE TABLE triaje (
  id_triaje     INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion   INT UNSIGNED NOT NULL UNIQUE,
  prioridad     ENUM('ROJA','NARANJA','AMARILLA','VERDE') NOT NULL,
  realizado_por INT UNSIGNED NOT NULL,
  realizado_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (realizado_por) REFERENCES usuario(id_usuario)
);

-- Reglas que se activaron en cada triaje (trazabilidad / auditoría)
CREATE TABLE triaje_regla_aplicada (
  id_triaje INT UNSIGNED NOT NULL,
  id_regla  INT UNSIGNED NOT NULL,
  PRIMARY KEY (id_triaje, id_regla),
  FOREIGN KEY (id_triaje) REFERENCES triaje(id_triaje),
  FOREIGN KEY (id_regla) REFERENCES regla_triaje(id_regla)
);

-- ---------- Registro clínico ----------
CREATE TABLE consulta_medica (
  id_consulta  INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion  INT UNSIGNED NOT NULL,
  id_medico    INT UNSIGNED NOT NULL,
  anamnesis    TEXT,
  examen_fisico TEXT,
  impresion_clinica TEXT,
  conducta     TEXT,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (id_medico) REFERENCES usuario(id_usuario)
);

CREATE TABLE nota_enfermeria (
  id_nota      INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion  INT UNSIGNED NOT NULL,
  id_usuario   INT UNSIGNED NOT NULL,
  nota         TEXT NOT NULL,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE evolucion (
  id_evolucion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion  INT UNSIGNED NOT NULL,
  id_usuario   INT UNSIGNED NOT NULL,
  descripcion  TEXT NOT NULL,
  fecha        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE epicrisis (
  id_epicrisis INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  id_atencion  INT UNSIGNED NOT NULL UNIQUE,
  resumen      TEXT NOT NULL,
  diagnostico_egreso VARCHAR(255),
  indicaciones_egreso TEXT,
  generada_por INT UNSIGNED NOT NULL,
  generada_en  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
  FOREIGN KEY (generada_por) REFERENCES usuario(id_usuario)
);

-- =====================================================
-- Datos iniciales
-- =====================================================
INSERT INTO rol (nombre) VALUES ('ADMIN'), ('MEDICO'), ('ENFERMERIA'), ('ADMISION');

INSERT INTO sintoma (nombre) VALUES
 ('Dolor torácico'), ('Dificultad respiratoria'), ('Fiebre'), ('Vómito persistente'),
 ('Diarrea'), ('Cefalea intensa'), ('Pérdida de conciencia'), ('Convulsiones'),
 ('Dolor abdominal'), ('Sangrado activo');

-- Umbrales DE EJEMPLO: deben validarse y documentarse como "reglas definidas para el proyecto".
-- No constituyen diagnóstico médico.
INSERT INTO regla_triaje (descripcion, parametro, operador, valor_umbral, id_sintoma, prioridad) VALUES
 ('Saturación de O2 muy baja',        'SATURACION_O2',          '<',  90,   NULL, 'ROJA'),
 ('Frecuencia cardiaca muy alta',     'FRECUENCIA_CARDIACA',    '>',  130,  NULL, 'ROJA'),
 ('Presión sistólica muy baja',       'PRESION_SISTOLICA',      '<',  90,   NULL, 'ROJA'),
 ('Frecuencia respiratoria alta',     'FRECUENCIA_RESPIRATORIA','>',  30,   NULL, 'NARANJA'),
 ('Fiebre alta',                      'TEMPERATURA',            '>=', 39.5, NULL, 'NARANJA'),
 ('Fiebre moderada',                  'TEMPERATURA',            '>=', 38,   NULL, 'AMARILLA'),
 ('Pérdida de conciencia',            'SINTOMA',                '=',  NULL, 7,    'ROJA'),
 ('Convulsiones',                     'SINTOMA',                '=',  NULL, 8,    'ROJA'),
 ('Dificultad respiratoria',          'SINTOMA',                '=',  NULL, 2,    'NARANJA'),
 ('Dolor torácico',                   'SINTOMA',                '=',  NULL, 1,    'NARANJA');
