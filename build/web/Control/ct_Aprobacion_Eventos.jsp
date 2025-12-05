<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // =============================
    // VALIDAR SESIÓN DE ADMIN
    // =============================
    Long adminId = (Long) session.getAttribute("adminId");

    if (adminId == null) {
        response.sendRedirect("../Vista/LoginAdmin.jsp");
        return;
    }

    // =============================
    // OBTENER PARÁMETROS
    // =============================
    String idParam = request.getParameter("id");
    String accion = request.getParameter("accion");

    if (idParam == null || accion == null) {
        response.sendRedirect("../Vista/AprobacionEventos.jsp");
        return;
    }

    int id = Integer.parseInt(idParam);

    // =============================
    // PROCESAR ACCIÓN
    // =============================
    EventDAO dao = new EventDAO();

    String msg = "";
    String type = "";

    if ("aprobar".equals(accion)) {
        dao.aprobarEvento(id, adminId);
        msg = "El evento fue aprobado correctamente";
        type = "success";
    } else if ("rechazar".equals(accion)) {
        dao.rechazarEvento(id, adminId);
        msg = "El evento fue rechazado";
        type = "error";
    } else {
        msg = "Acción inválida";
        type = "error";
    }

    // =============================
    // REDIRECCIÓN CON MENSAJE
    // =============================
    response.sendRedirect("../Vista/AprobacionEventos.jsp?msg=" 
        + java.net.URLEncoder.encode(msg, "UTF-8")
        + "&type=" + type);
%>