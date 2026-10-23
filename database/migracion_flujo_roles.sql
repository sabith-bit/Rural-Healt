-- Migración aditiva para RuralHealth. No borra tablas ni registros existentes.
USE ruralhealth;
INSERT INTO rol(nombre) SELECT 'BACTERIOLOGIA' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre='BACTERIOLOGIA');
CREATE TABLE IF NOT EXISTS indicacion_medica (
 id_indicacion INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
 id_atencion INT UNSIGNED NOT NULL, id_medico INT UNSIGNED NOT NULL,
 tipo VARCHAR(30) NOT NULL, descripcion VARCHAR(500) NOT NULL,
 dosis VARCHAR(120), via VARCHAR(80), frecuencia VARCHAR(120), duracion VARCHAR(120),
 estado VARCHAR(30) NOT NULL DEFAULT 'PENDIENTE', nota_enfermeria TEXT,
 creada_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, actualizada_en DATETIME NULL,
 FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
 FOREIGN KEY (id_medico) REFERENCES usuario(id_usuario), INDEX idx_indicacion_estado(estado,creada_en)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS orden_examen (
 id_orden INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, id_atencion INT UNSIGNED NOT NULL,
 id_medico INT UNSIGNED NOT NULL, tipo_examen VARCHAR(160) NOT NULL,
 indicaciones TEXT, estado VARCHAR(30) NOT NULL DEFAULT 'SOLICITADO',
 solicitado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, actualizado_en DATETIME NULL,
 FOREIGN KEY (id_atencion) REFERENCES atencion(id_atencion),
 FOREIGN KEY (id_medico) REFERENCES usuario(id_usuario), INDEX idx_examen_estado(estado,solicitado_en)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS resultado_examen (
 id_resultado INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, id_orden INT UNSIGNED NOT NULL UNIQUE,
 id_bacteriologo INT UNSIGNED NOT NULL, resultado TEXT NOT NULL, observaciones TEXT,
 registrado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_orden) REFERENCES orden_examen(id_orden),
 FOREIGN KEY (id_bacteriologo) REFERENCES usuario(id_usuario)
) ENGINE=InnoDB;
