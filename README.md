# Mensajería BigBoss

Plataforma de mensajería web (Proyecto Final) con:

- Registro / Login con sesión única (se cierra la sesión anterior si se inicia en otro lugar).
- Recuperación de contraseña para usuarios vía código enviado por correo.
- Recuperación / restablecimiento especial para administrador mediante clave secreta del servidor.
- Mensajes públicos (tablón comunitario).
- Chat privado entre usuarios (incluye polling y notificaciones visuales in–app).
- Sistema de solicitudes de contacto (los usuarios envían “tickets” y el admin los gestiona).
- Panel de administración separado.
- Docker + Nginx como reverse proxy + Node.js (Express) como backend.
- Persistencia de datos en archivos JSON dentro de /app/data (montable como volumen).
- Intro “tipo videojuego” y estética retro (fuente Minecraftia, animaciones, canvas interactivo).
- Reproductor musical básico y notificaciones emergentes.

---

## Demo Rápida con Docker (Imagen Publicada)

```bash
# Descargar imagen
docker pull jendri0842/mensajeria-bigboss:latest

# Ejecutar contenedor (puerto 80 y volumen para persistir datos)
docker run -d -p 80:80 \
  -v $(pwd)/data:/app/data \
  --name mensajeria \
  jendri0842/mensajeria-bigboss:latest
```

---

## Acceso a la Aplicación

- Cliente (usuarios):  
  - http://127.0.0.1  
  - http://localhost

- Panel Administrador:  
  - http://127.0.0.1/admin-template/admin.html  
  - http://localhost/admin-template/admin.html  

Credenciales iniciales del admin (se generan si no existe el archivo):
```
Usuario: admin
Password: api#12345
```

## Estructura del Repositorio

```
Mensajeria-BigBoss/
├─ Source/
│  ├─ API-Dary.js             
│  ├─ package.json             
│  ├─ package-lock.json          
│  ├─ public/
│  │  └─ index.html             
│  ├─ admin-template/
│  │  └─ admin.html             
│  └─ data/                    
├─ nginx.conf                    
├─ Dockerfile                    
├─ start.sh                      
└─  README.md
```

---

## Flujo de Funcionalidades

1. Usuario se registra (usuario + email + contraseña validada).
2. Inicia sesión (sesión única: si entra desde otro dispositivo expulsa la anterior).
3. Puede:
   - Enviar mensajes públicos.
   - Buscar usuarios y abrir chat privado (con notificaciones emergentes si llegan mensajes).
   - Enviar solicitudes de contacto (tipo ticket) al admin.
4. Admin:
   - Gestiona usuarios (crear / eliminar / resetear pass).
   - Revisa y responde solicitudes (Aprobada / Rechazada con mensaje).
   - Elimina mensajes públicos o chats completos.
5. Recuperación de contraseña:
   - Usuario: recibe código por email (6 dígitos / 5 min).
   - Admin: flujo especial con clave secreta del servidor para generar token temporal.

---

## Recuperación de Contraseña

| Actor     | Método | Descripción |
|-----------|--------|-------------|
| Usuario   | `/usuarios/solicitar_recuperacion` | Envía email con código (SMTP) |
| Usuario   | `/usuarios/verificar_codigo`       | Verifica código válido |
| Usuario   | `/usuarios/restablecer_password`   | Cambia contraseña (invalida sesión) |
| Admin     | `/admin/solicitar_recuperacion`    | Usa serverKey (secreta) para generar token (en consola) |
| Admin     | `/admin/restablecer_password`      | Cambia contraseña admin |

---

## API (Resumen de Endpoints)

(Autenticación vía token Bearer devuelto en login; expira en 1h)

### Autenticación Usuario
- POST `/usuarios/registro`
- POST `/usuarios/login`
- POST `/usuarios/logout`
- POST `/usuarios/solicitar_recuperacion`
- POST `/usuarios/verificar_codigo`
- POST `/usuarios/restablecer_password`

### Autenticación Admin
- POST `/admin/login`
- POST `/admin/logout`
- POST `/admin/solicitar_recuperacion`
- POST `/admin/restablecer_password`

### Usuarios
- GET `/usuarios` (token usuario; lista nombres)
- (Admin) GET `/admin/usuarios`
- (Admin) POST `/admin/usuarios`
- (Admin) DELETE `/admin/usuarios/:usuario`
- (Admin) PUT `/admin/usuarios/:usuario/password`

### Mensajes Públicos
- GET `/mensajes`
- POST `/mensajes`
- DELETE `/mensajes/:id` (autor del mensaje)
- (Admin) DELETE `/admin/mensajes/:id`

### Mensajes Privados
- GET `/mensajes_privados/:usuario`
- GET `/mensajes_privados/nuevos/:usuarioActual/:usuarioRemitente`
- POST `/mensajes_privados`
- PUT `/mensajes_privados/marcar_leidos/:usuarioActual/:usuarioRemitente`
- DELETE `/mensajes_privados/chat/:user1/:user2`
- (Admin) GET `/admin/mensajes_privados?user1=...&user2=...`
- (Admin) DELETE `/admin/mensajes_privados/chat/:user1/:user2`

### Solicitudes de Contacto
- POST `/solicitudes`
- GET `/solicitudes/mis_solicitudes`
- (Admin) GET `/admin/solicitudes`
- (Admin) PUT `/admin/solicitudes/:id/aprobar`
- (Admin) PUT `/admin/solicitudes/:id/rechazar`
- (Admin) DELETE `/admin/solicitudes/:id`
