<%-- 
    Document   : DashboardAdministrador
    Created on : 19/10/2025, 10:12:55 p. m.
    Author     : Migue
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Verificación de sesión
    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
        // Si no hay sesión de admin, redirige al login
        response.sendRedirect(request.getContextPath() + "/Vista/LoginAdmin.jsp");
        return;
    }

    String adminNombre = (String) session.getAttribute("adminNombre");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrativo — Livepass Buga</title>
</head>
<body>
    <h1>Bienvenido al Backoffice, <%= adminNombre != null ? adminNombre : "Administrador" %>!</h1>

    <p>Aquí será el panel administrativo con acceso a:</p>
    <ul>
        <li><a href="<%= request.getContextPath() %>/Vista/CrearAdministrador.jsp">Crear adminsitrador</a></li>
        <li><a href="<%= request.getContextPath() %>/Vista/ListarEditarAdministrador.jsp">Listar / Editar administradores</a></li>
        <li><a href="<%= request.getContextPath() %>/Vista/AprobacionOrganizadores.jsp">Aprobación de organizadores</a></li>
        <li><a href="<%= request.getContextPath() %>/Vista/DashboardVentas.jsp">Dashboard de ventas</a></li>
        <li><a href="<%= request.getContextPath() %>/Vista/ReportesFinancieros.jsp">Reportes financieros</a></li>
    
    </ul>

    <form action="<%= request.getContextPath() %>/Control/ct_logout_admin.jsp" method="post">
        <button type="submit">Cerrar sesión</button>
    </form>
</body>
</html>