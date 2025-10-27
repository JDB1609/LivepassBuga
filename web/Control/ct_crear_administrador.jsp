<%@ page import="dao.AdministradorDAO, utils.Administrador" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<%
    request.setCharacterEncoding("UTF-8");

    String mensaje;

    try {
        // Captura de parámetros del formulario (usa los NOMBRES reales del form)
        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("nombre");
        String email = request.getParameter("email");
        String phone = request.getParameter("telefono");
        String password = request.getParameter("pass");
        String password2 = request.getParameter("pass2");

        // Validación básica
        if (password == null || !password.equals(password2)) {
            mensaje = "Las contraseñas no coinciden.";
            response.sendRedirect(request.getContextPath() + "/Vista/CrearAdministrador.jsp?error=" + mensaje);
            return;
        }

        // Crear DAO y registrar administrador
        AdministradorDAO dao = new AdministradorDAO();
        boolean exito = dao.create(id, name, email, phone, password, Administrador.Status.ACTIVO);

        if (exito) {
            mensaje = "Administrador registrado correctamente.";
            response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp?success=" + mensaje);
        } else {
            mensaje = "No se pudo registrar el administrador.";
            response.sendRedirect(request.getContextPath() + "/Vista/CrearAdministrador.jsp?error=" + mensaje);
        }

    } catch (NumberFormatException e) {
        mensaje = "El ID debe ser un número válido.";
        response.sendRedirect(request.getContextPath() + "/Vista/CrearAdministrador.jsp?error=" + mensaje);
    } catch (Exception e) {
        e.printStackTrace();
        mensaje = "Error interno: " + e.getMessage();
        response.sendRedirect(request.getContextPath() + "/Vista/CrearAdministrador.jsp?error=" + mensaje);
    }
%>