<%@ page import="dao.AdministradorDAO, utils.Administrador" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
request.setCharacterEncoding("UTF-8");

Map<String,String> errors = new HashMap<>();

String sid      = request.getParameter("id");
String nombre   = request.getParameter("nombre");
String email    = request.getParameter("email");
String tel      = request.getParameter("telefono");
String pass     = request.getParameter("pass");
String pass2    = request.getParameter("pass2");

// Reenviar valores al formulario
request.setAttribute("f_id", sid);
request.setAttribute("f_nombre", nombre);
request.setAttribute("f_email", email);
request.setAttribute("f_tel", tel);

// VALIDACIONES
if (sid == null || !sid.matches("\\d+"))
    errors.put("id", "La cédula es inválida.");

if (nombre == null || nombre.trim().isEmpty())
    errors.put("nombre", "El nombre es obligatorio.");

if (email == null || !email.contains("@"))
    errors.put("email", "Correo inválido.");

if (pass == null || pass.length() < 8)
    errors.put("pass", "La contraseña debe tener mínimo 8 caracteres.");

if (pass2 == null || !pass.equals(pass2))
    errors.put("pass2", "Las contraseñas no coinciden.");

// SI HAY ERRORES → VOLVER AL FORMULARIO
if (!errors.isEmpty()) {
    request.setAttribute("errors", errors);
    request.getRequestDispatcher("../Vista/CrearAdministrador.jsp").forward(request, response);
    return;
}

// GUARDAR EN BD
try {
    int id = Integer.parseInt(sid);

    AdministradorDAO dao = new AdministradorDAO();
    boolean exito = dao.create(id, nombre, email, tel, pass, Administrador.Status.ACTIVO);

    if (!exito) {
        errors.put("global", "No se pudo registrar el administrador.");
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("../Vista/CrearAdministrador.jsp").forward(request, response);
        return;
    }

    // ✅ ÉXITO
    response.sendRedirect(
        request.getContextPath() + "/Vista/CrearAdministrador.jsp?success=1"
    );

} catch (Exception e) {

    if (e.getMessage().contains("Duplicate entry")) {
        errors.put("global", "❌ Ya existe un administrador con esa cédula o ese correo electronico.");
    } else {
        errors.put("global", "❌ Error interno del sistema.");
    }

    request.setAttribute("errors", errors);
    request.getRequestDispatcher("../Vista/CrearAdministrador.jsp").forward(request, response);
}
%>