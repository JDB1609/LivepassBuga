<%@ page contentType="image/png" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="dao.TicketDAO, java.util.Optional" %>
<%@ page import="utils.QrUtil" %>
<%
  // Cabeceras para evitar caché
  response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
  response.setHeader("Pragma", "no-cache");

  // Sesión
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendError(401); return; }

  // Parámetros
  int tid = 0, size = 320;
  try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  try { size = Math.max(128, Math.min(1024, Integer.parseInt(request.getParameter("s")))); } catch(Exception ignore){}
  if (tid <= 0) { response.sendError(400, "tid requerido"); return; }

  // Cargar ticket y verificar propietario
  TicketDAO dao = new TicketDAO();
  Optional<utils.Ticket> opt = dao.findForUser(tid, uid);
  if (!opt.isPresent()) { response.sendError(404); return; }
  utils.Ticket t = opt.get();

  // Payload del QR (usa el guardado o genera uno con firma corta)
  String secret = application.getInitParameter("qr.secret");
  if (secret == null) secret = "demo-secret";

  String payload = t.getQrCode();
  if (payload == null || payload.trim().isEmpty()) {
    String sec = QrUtil.sha256Hex(t.getId()+"|"+t.getEventId()+"|"+uid+"|"+secret).substring(0, 12);
    payload = "LP|TID="+t.getId()+"|EV="+t.getEventId()+"|USR="+uid+"|SEC="+sec;
    // Si quieres persistirlo: UPDATE tickets SET qr_code=? WHERE id=?
  }

  // Generar PNG y escribirlo
  byte[] png = QrUtil.png(payload, size);
  javax.servlet.ServletOutputStream os = response.getOutputStream();
  os.write(png);
  os.flush();
%><%-- EOF --%>
