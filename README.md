# RuralHealth — aplicación web de gestión clínica rural

Versión de proyecto académico con interfaz web, backend Java/Spring Boot y conexión a MariaDB/MySQL de XAMPP.

## Importante: conservar la base de datos que ya tienes

Esta entrega está configurada para conectarse a la base local `ruralhealth` que ya importaste en phpMyAdmin:

- URL: `jdbc:mariadb://localhost:3306/ruralhealth`
- Usuario: `root`
- Contraseña: vacía (configuración habitual de XAMPP local)
- Puerto web: `8080`

**No vuelvas a importar `database/ruralhealth_schema.sql` si ya tienes datos que quieras conservar.** Ese archivo contiene `DROP DATABASE IF EXISTS ruralhealth` y recrearía la base, eliminando sus datos actuales. La aplicación usa `spring.jpa.hibernate.ddl-auto=none`, por lo que Hibernate no crea ni borra las tablas.

Si tu usuario o contraseña de MariaDB son diferentes, cambia únicamente `src/main/resources/application.properties`.

## Requisitos

- JDK 21 o superior compatible con Spring Boot 3.3.
- XAMPP instalado y MySQL/MariaDB iniciado.
- Visual Studio Code con Extension Pack for Java / Spring Boot Extension Pack.
- Conexión a internet la primera vez para que Maven descargue dependencias.

## Abrir y ejecutar

1. Descomprime `RuralHealth_Proyecto_Completo.zip`.
2. En VS Code selecciona **Archivo → Abrir carpeta** y abre la carpeta `RuralHealth` (la que contiene `pom.xml`). No abras solo `src` ni `static`.
3. Inicia **MySQL** en XAMPP.
4. Abre `src/main/java/com/ruralhealth/backend/BackendApplication.java` y pulsa **Run** sobre el método `main`.
5. Espera el mensaje `Started BackendApplication`.
6. Abre Chrome en **http://localhost:8080**. No uses Live Server/puerto 5500 para esta versión: Spring Boot sirve la página web y la API desde el puerto 8080.

## Módulos incluidos

- Panel principal con indicadores y atenciones recientes.
- Registro, búsqueda, edición e historial de pacientes.
- Creación y cola de atenciones.
- Registro de signos vitales y selección de síntomas. Al seleccionar una atención se muestra el formulario y se recuperan los últimos signos y síntomas guardados.
- El botón de calcular triaje guarda primero la medición actual y los síntomas seleccionados para clasificar con los datos más recientes.
- Ejecución de reglas de triaje existentes y visualización de las reglas activadas.
- Historia clínica con consulta médica, notas de enfermería, evoluciones y epicrisis.
- Cierre de atención, condicionado a que exista una epicrisis.
- Catálogo de reglas de triaje y listado de usuarios/roles.
- Interfaz adaptable a computadores y celulares.

## Acceso por roles

La aplicación incluye inicio de sesión con sesión de servidor, contraseñas BCrypt y permisos de backend mediante Spring Security. La navegación y las funciones visibles dependen del rol:

- **ADMIN:** panel, pacientes, atenciones, triaje, historia, reglas, personal, indicaciones y exámenes.
- **ENFERMERIA:** registro/consulta de pacientes, signos vitales, triaje, notas y seguimiento de indicaciones médicas.
- **MEDICO:** cola de atención por prioridad, historia clínica, consulta, indicaciones/recetas y solicitud/consulta de exámenes.
- **BACTERIOLOGIA:** órdenes de laboratorio y carga de resultados para el médico.
- **ADMISION:** registro de pacientes y apertura de atenciones.

Si la tabla `usuario` estaba vacía, el proyecto base crea cuentas de demostración con la contraseña inicial `Cambiar123*`: `admin@ruralhealth.com`, `medico@ruralhealth.com` y `enfermeria@ruralhealth.com`. Si ya existían usuarios en la base, esas cuentas no se recrean; utiliza las credenciales que ya tengas. Después de entrar como administrador, crea las cuentas adicionales desde **Personal y roles**. El rol BACTERIOLOGIA y las tablas nuevas se incorporan mediante cambios aditivos al arrancar, sin borrar los datos anteriores.

## Flujo clínico incorporado

1. Enfermería/admisión registra al paciente y abre la atención.
2. Enfermería registra signos y síntomas y calcula la prioridad con las reglas configuradas.
3. Medicina consulta la cola priorizada y registra la consulta.
4. El médico envía indicaciones para enfermería o solicita exámenes de laboratorio.
5. Enfermería registra recepción/cumplimiento de indicaciones; bacteriología carga el resultado y el médico puede consultarlo.
6. El médico registra la epicrisis y cierra la atención.

Las nuevas tablas `indicacion_medica`, `orden_examen` y `resultado_examen` se crean con `CREATE TABLE IF NOT EXISTS`. También se incluye `database/migracion_flujo_roles.sql` como migración manual documentada; no importes el esquema inicial si ya tienes información clínica que conservar.

**Importante:** es un prototipo académico. Los umbrales de triaje y las decisiones clínicas deben ser validados por profesionales. Antes de usar datos reales o publicar el sistema en internet, hace falta una revisión de seguridad, privacidad, copias de seguridad, auditoría clínica y pruebas integrales.

## API principal

- `GET /api/dashboard`
- `GET /api/usuarios`
- `GET /api/pacientes?q=texto`, `POST /api/pacientes`, `GET/PUT /api/pacientes/{id}`
- `GET /api/pacientes/{id}/atenciones`
- `GET /api/atenciones/cola`, `GET /api/atenciones/todas`, `POST /api/atenciones`
- `POST /api/atenciones/{id}/signos`
- `PUT /api/atenciones/{id}/sintomas`
- `POST /api/atenciones/{id}/triaje`
- `GET /api/atenciones/{id}/historia`
- `POST /api/atenciones/{id}/consulta`
- `POST /api/atenciones/{id}/notas-enfermeria`
- `POST /api/atenciones/{id}/evoluciones`
- `POST /api/atenciones/{id}/epicrisis`
- `PUT /api/atenciones/{id}/cerrar`
- `POST /api/auth/login`, `GET /api/auth/me`, `POST /api/auth/logout`
- `GET/POST /api/admin/usuarios` (solo ADMIN)
- `GET/POST /api/workflow/indicaciones`, `PUT /api/workflow/indicaciones/{id}/estado`
- `GET/POST /api/workflow/examenes`, `PUT /api/workflow/examenes/{id}/resultado`
- `GET /api/sintomas`, `GET /api/reglas-triaje` (reglas solo ADMIN)

## Nota clínica

Las reglas y umbrales del triaje incluidos en el esquema son datos de ejemplo para el proyecto académico; deben validarse con profesionales competentes. El resultado del sistema es apoyo operativo y no constituye diagnóstico médico.
