<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO" %>
<%@ page import="java.io.*" %>

<%
    // Obtener parámetros
    String strId = request.getParameter("id");
    String action = request.getParameter("action");
    Long adminId = (Long) session.getAttribute("adminId");

    if (strId == null || action == null || adminId == null) {
        session.setAttribute("msgEvento", "Parámetros inválidos.");
        response.sendRedirect(request.getContextPath() + "/Vista/BackofficeAdministrador.jsp");
        return;
    }

    int eventId = Integer.parseInt(strId);
    EventDAO eventDAO = new EventDAO();
    boolean success = false;

    if ("aprobar".equalsIgnoreCase(action)) {
        success = eventDAO.aprobarEvento(eventId, adminId);
    } else if ("rechazar".equalsIgnoreCase(action)) {
        success = eventDAO.rechazarEvento(eventId, adminId);
    }

    // Mensaje según resultado
    if (success) {
        session.setAttribute("msgEvento", "Evento " + action + "ado correctamente.");
    } else {
        session.setAttribute("msgEvento", "No se pudo " + action + " el evento. Verifique los datos.");
    }

    // Redirigir de vuelta al panel
    response.sendRedirect(request.getContextPath() + "/Vista/BackofficeAdministrador.jsp");
%>