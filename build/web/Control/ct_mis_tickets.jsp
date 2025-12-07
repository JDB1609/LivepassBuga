<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="dao.TicketDAO, utils.Ticket" %>
<%
    // Validar sesión
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) { 
        response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp"); 
        return; 
    }

    // Cargar tickets futuros y pasados del usuario
    TicketDAO tdao = new TicketDAO();
    List<Ticket> upcoming = tdao.listUpcomingByUser(uid); 
    List<Ticket> past     = tdao.listPastByUser(uid);

    // Enviar a la vista (JSP)
    request.setAttribute("upcoming", upcoming);
    request.setAttribute("past", past);
%>
