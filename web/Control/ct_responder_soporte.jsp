<%@ page import="dao.SoporteDAO" %>

<%
    int id = Integer.parseInt(request.getParameter("id"));
    String respuesta = request.getParameter("respuesta");

    SoporteDAO dao = new SoporteDAO();
    boolean ok = dao.responder(id, respuesta);

    if (ok) {
        response.sendRedirect("../Vista/SoporteAdministrador.jsp?msg=ok");
    } else {
        response.sendRedirect("../Vista/SoporteAdministrador.jsp?msg=err");
    }
%>