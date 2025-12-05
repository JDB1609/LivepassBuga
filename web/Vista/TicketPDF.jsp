<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TicketDAO, utils.Ticket" %>
<%@ page import="java.security.MessageDigest, java.nio.charset.StandardCharsets" %>

<%
  String ctx = request.getContextPath();

  // --- Guard de sesión ---
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(ctx + "/Vista/Login.jsp"); return; }

  // --- Param y carga de ticket (verifica dueño) ---
  int tid = 0;
  try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  TicketDAO dao = new TicketDAO();
  Ticket t = (tid>0) ? dao.findForUser(tid, uid).orElse(null) : null;
  if (t == null) { response.sendRedirect(ctx + "/Vista/MisTickets.jsp"); return; }

  // --- Construcción del payload para el QR ---
  String payload = null;

  // 1) Si guardas el QR en BD, úsalo
  if (t.getQrCode()!=null && !t.getQrCode().isEmpty()) {
    payload = t.getQrCode();
  } else {
    // 2) Si no hay qr_code en BD, genera uno con firma SHA-256
    String secret = "LP-SECRET"; // TODO: cámbialo por uno propio
    String base   = t.getId()+"|"+t.getEventId()+"|"+uid+"|"+secret;
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] dig = md.digest(base.getBytes(StandardCharsets.UTF_8));
    StringBuilder sb = new StringBuilder();
    for (byte b : dig) sb.append(String.format("%02x", b));
    String sig = sb.toString();

    payload = "LP|TID="+t.getId()+"|EV="+t.getEventId()+"|USR="+uid+"|SIG="+sig;
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>QR Ticket</title>
  <style>
    .qr-box{background:rgba(255,255,255,.06);border-radius:18px;padding:24px;
            box-shadow:0 10px 40px rgba(0,0,0,.45),inset 0 1px 0 rgba(255,255,255,.04)}
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-xl mx-auto px-5 py-10">
    <h1 class="text-2xl font-extrabold mb-2"><%= t.getEventTitle()!=null?t.getEventTitle():"Ticket" %> — QR</h1>
    <p class="text-white/70 mb-6">Muestra este código en el acceso.</p>

    <div class="qr-box flex items-center justify-center">
      <div id="qr"></div>
    </div>

    <div class="mt-4 text-white/60 break-all text-xs">
      Payload: <%= payload %>
    </div>

    <div class="mt-6 flex gap-2">
      <a class="btn-ghost ripple" href="<%= ctx %>/Vista/MisTickets.jsp">Volver a mis tickets</a>
      <a class="btn-primary ripple" href="<%= ctx %>/Vista/TicketPDF.jsp?tid=<%= t.getId() %>">Descargar PDF</a>
    </div>
  </main>

  <!-- QR (client side) -->
  <script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
  <script>
    const payload = <%= "\""+payload.replace("\"","\\\"")+"\"" %>;
    const c = document.createElement('canvas');
    QRCode.toCanvas(c, payload, { width: 260, margin: 1 }, function(){});
    document.getElementById('qr').appendChild(c);

    (function(){ document.querySelectorAll('.ripple').forEach(function(b){
      b.addEventListener('click',function(e){
        var r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
        s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
        this.appendChild(s); setTimeout(function(){s.remove();},600);
      });
    });})();
  </script>
</body>
</html>
