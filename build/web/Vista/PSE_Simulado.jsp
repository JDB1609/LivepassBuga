<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String ctx = request.getContextPath();
  String eventId = request.getParameter("eventId");
  String qty     = request.getParameter("qty");
  String amount  = request.getParameter("amount");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <title>Simulador PSE</title>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <style>
    :root{
      --bg:#0b0e16; --panel:#141a26; --border:rgba(255,255,255,.12);
      --text:#eaeef7; --muted:rgba(255,255,255,.70);
      --primary:#01c7b8; --primary-ink:#04131b; --danger:#ff7890;
    }
    *{box-sizing:border-box}
    html,body{height:100%}
    body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,Inter,Arial;color:var(--text);background:var(--bg)}
    .wrap{max-width:720px;margin:48px auto;padding:0 20px}
    .card{border:1px solid var(--border);border-radius:18px;background:rgba(255,255,255,.04)}
    .head{padding:18px 20px;border-bottom:1px solid var(--border)}
    .body{padding:18px 20px}
    .title{font-size:1.35rem;font-weight:800;display:flex;gap:.6rem;align-items:center}
    .muted{color:var(--muted)}
    .row{display:grid;gap:12px}
    .row.cols-2{grid-template-columns:1fr 1fr}
    label{display:block;font-size:.9rem;margin:8px 0 6px;color:var(--muted)}
    .input,.select{
      width:100%;padding:.85rem 1rem;border-radius:12px;background:transparent;
      border:1px solid var(--border);color:var(--text);outline:none;
      transition:border-color .15s, box-shadow .15s;
      appearance:none;
    }
    .select{background-image:linear-gradient(45deg,transparent 50%,var(--text) 50%),linear-gradient(135deg,var(--text) 50%,transparent 50%),linear-gradient(to right,transparent,transparent);
            background-position:calc(100% - 22px) calc(1em + 4px),calc(100% - 12px) calc(1em + 4px),100% 0;
            background-size:10px 10px,10px 10px,2.5em 2.5em;background-repeat:no-repeat}
    .input:focus,.select:focus{border-color:rgba(1,199,184,.7);box-shadow:0 0 0 3px rgba(1,199,184,.18) inset}
    .actions{display:flex;gap:10px;justify-content:flex-end;margin-top:18px}
    .btn{padding:.8rem 1.1rem;border-radius:12px;border:1px solid var(--border);color:var(--text);background:transparent;cursor:pointer}
    .btn.primary{background:var(--primary);border-color:var(--primary);color:var(--primary-ink);font-weight:800}
    .btn.ghost{border-color:var(--border)}
    @media (max-width:700px){ .row.cols-2{grid-template-columns:1fr} }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <div class="head">
        <div class="title">🏦 <span>Simulador PSE</span></div>
      </div>
      <div class="body">
        <p class="muted">Estás pagando <b><%= amount %></b>. La referencia se generará al aprobar.</p>

        <form method="post" action="<%= ctx %>/Control/ct_pago_simulado.jsp" novalidate>
          <input type="hidden" name="paymentMethod" value="PSE">
          <input type="hidden" name="eventId" value="<%= eventId %>">
          <input type="hidden" name="qty" value="<%= qty %>">
          <input type="hidden" name="amount" value="<%= amount %>">
          <input type="hidden" name="back" value="/Vista/PagoSimulado.jsp">

          <label>Selecciona tu banco</label>
          <select name="bank" class="select" required>
            <option value="" selected>— Elegir —</option>
            <option value="Bancolombia">Bancolombia</option>
            <option value="BBVA">BBVA</option>
            <option value="Davivienda">Davivienda</option>
            <option value="Banco de Bogotá">Banco de Bogotá</option>
          </select>

          <div class="row cols-2" style="margin-top:12px">
            <div>
              <label>Usuario</label>
              <input class="input" name="user" required placeholder="usuario del banco">
            </div>
            <div>
              <label>Clave</label>
              <input class="input" name="pass" type="password" required placeholder="••••••••">
            </div>
          </div>

          <div class="actions">
            <button class="btn ghost" name="approved" value="no" type="submit">Rechazar</button>
            <button class="btn primary" name="approved" value="yes" type="submit">Aprobar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</body>
</html>
