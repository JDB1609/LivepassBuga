<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO" %>

<%
    request.setCharacterEncoding("UTF-8");

    // ===== VALIDAR SESIÓN Y ROL =====
    Integer uid  = (Integer) session.getAttribute("userId");
    String  role = (String)  session.getAttribute("role");

    if (uid == null || role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp");
        return;
    }

    // ===== LEER Y VALIDAR ID DEL EVENTO =====
    String idStr = request.getParameter("id");

    if (idStr == null || idStr.isBlank()) {
        response.sendRedirect(request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=0&err=sin_id");
        return;
    }

    try {
        int eventId = Integer.parseInt(idStr.trim());

        EventDAO eventDao = new EventDAO();
        eventDao.delete(eventId, uid);   // ← ahora sí va a existir

        response.sendRedirect(request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=1");

    } catch (NumberFormatException nfe) {
        nfe.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=0&err=id_invalido");
    } catch (Exception ex) {
        ex.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=0&err=delete_fail");
    }
%>
