<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TicketDAO, utils.Ticket, utils.Conexion" %>
<%
  Integer fromId = (Integer) session.getAttribute("userId");
  if (fromId == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  int tid = 0; try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  String toEmail = request.getParameter("toEmail");

  TicketDAO dao = new TicketDAO();
  try {
    int toId = dao.findUserIdByEmail(toEmail); // -1 si no existe
    if (toId <= 0) {
      response.sendRedirect(request.getContextPath()+"/Vista/TicketTransfer.jsp?tid="+tid+"&msg=El usuario destino no existe.");
      return;
    }
    boolean ok = dao.transfer(tid, fromId, toId);
    if (ok) {
      response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp?msg=Transferencia%20realizada");
    } else {
      response.sendRedirect(request.getContextPath()+"/Vista/TicketTransfer.jsp?tid="+tid+"&msg=No%20se%20pudo%20transferir.%20Verifica%20estado%20del%20ticket.");
    }
  } catch (Exception ex) {
    response.sendRedirect(request.getContextPath()+"/Vista/TicketTransfer.jsp?tid="+tid+"&msg=Error:%20"+java.net.URLEncoder.encode(ex.getMessage(),"UTF-8"));
  }
%>
