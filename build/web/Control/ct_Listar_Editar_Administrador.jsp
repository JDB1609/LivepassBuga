<%@ page import="dao.AdministradorDAO, utils.Administrador" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Verificación de sesión
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    AdministradorDAO dao = new AdministradorDAO();

    // Solo procesa POST para actualización
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String plainPass = request.getParameter("plainPass"); // opcional
            String statusStr = request.getParameter("status");
            Administrador.Status status = "INACTIVO".equalsIgnoreCase(statusStr) ? 
                                       Administrador.Status.INACTIVO : 
                                       Administrador.Status.ACTIVO;

            boolean ok = dao.update(id, name, email, phone, plainPass, status);
            response.sendRedirect(request.getContextPath() + 
                "/Vista/ListarEditarAdministrador.jsp?msg=" + (ok ? "ok" : "err"));
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect(request.getContextPath() + 
                "/Vista/ListarEditarAdministrador.jsp?msg=err");
        }
        return;
    }

    // Si no es POST, redirige a la vista
    response.sendRedirect(request.getContextPath() + "/Vista/ListarEditarAdministrador.jsp");
%>