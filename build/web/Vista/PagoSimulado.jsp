<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.math.BigDecimal, java.text.NumberFormat, java.util.Locale" %>

<%
  // --- Guard session ---
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  // --- Params ---
  int eventId = 0, qty = 1;
  try { eventId = Integer.parseInt(request.getParameter("eventId")); } catch(Exception ignore){}
  try { qty     = Math.max(1, Integer.parseInt(request.getParameter("qty"))); } catch(Exception ignore){}
  if (eventId <= 0) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // --- Data ---
  Event ev = new EventDAO().findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  BigDecimal unit  = (ev.getPriceValue() != null) ? ev.getPriceValue() : BigDecimal.ZERO;
  BigDecimal total = unit.multiply(BigDecimal.valueOf(qty));

  NumberFormat COP = NumberFormat.getCurrencyInstance(new Locale("es","CO"));
  String err = request.getParameter("err");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Pagar — <%= ev.getTitle() %></title>
  <style>
    .glassx{border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.04);border-radius:16px}
    .crumbs a{opacity:.8} .crumbs a:hover{opacity:1; text-decoration:underline}
    .steps{display:grid;grid-template-columns:repeat(3,1fr);gap:8px}
    .step{padding:10px 8px;border-radius:999px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.05);text-align:center;font-weight:700}
    .step.is-active{border-color:rgba(0,209,178,.6);background:rgba(0,209,178,.12)}
    .muted{color:rgba(255,255,255,.72)}
    .divider{height:1px;background:linear-gradient(90deg,transparent,rgba(255,255,255,.14),transparent);margin:12px 0}

    /* Inputs */
    .input{
      width:100%;padding:.85rem 1rem;border-radius:12px;background:transparent;
      border:1px solid rgba(255,255,255,.15);color:#fff;outline:none;
      font-variant-numeric: tabular-nums; font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
      letter-spacing:.02em;
    }
    .input:focus{border-color:rgba(255,255,255,.30)}
    .error{font-size:.8rem;color:#ff9aa2;display:none}
    .field.invalid .error{display:block}
    .field.invalid .input{border-color:#ff9aa2}

    /* Métodos de pago */
    .pm-wrap{display:grid;gap:10px;grid-template-columns:repeat(4, minmax(140px,1fr))}
    @media (max-width: 860px){ .pm-wrap{grid-template-columns:repeat(2,minmax(160px,1fr));} }
    @media (max-width: 420px){ .pm-wrap{grid-template-columns:1fr;} }
    .pm{
      display:flex;align-items:center;justify-content:center;gap:.5rem;
      height:46px;border:1px solid rgba(255,255,255,.15);border-radius:12px;
      background:rgba(255,255,255,.05);opacity:.9;cursor:pointer;user-select:none;
      transition:border-color .15s, box-shadow .15s, opacity .15s;
    }
    .pm:focus-within{ outline:2px solid rgba(255,255,255,.12); outline-offset:2px; }
    .pm.active{border-color:rgba(0,209,178,.6);opacity:1;box-shadow:0 0 0 2px rgba(0,209,178,.15) inset}
    .pm input{display:none}

    .sticky{position:sticky;top:88px}

    /* Modal */
    .modal{position:fixed;inset:0;display:none;align-items:center;justify-content:center;z-index:70}
    .modal.show{display:flex}
    .modal .backdrop{position:absolute;inset:0;background:rgba(10,12,18,.65);backdrop-filter:blur(3px)}
    .modal .content{position:relative;z-index:1;width:min(92vw,560px);border-radius:16px;border:1px solid rgba(255,255,255,.12);background:rgba(20,24,34,.98);padding:18px}
    .chip{display:inline-block;padding:.25rem .6rem;border-radius:999px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.06);font-weight:700;font-size:.85rem}
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-6">

    <!-- Breadcrumb + Pasos -->
    <div class="flex flex-col gap-3 mb-6">
      <nav class="crumbs text-sm">
        <a href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp">Inicio</a> /
        <a href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Eventos</a> /
        <span class="opacity-100 font-semibold">Pago</span>
      </nav>
      <div class="steps">
        <div class="step">1) Resumen</div>
        <div class="step is-active">2) Pago</div>
        <div class="step">3) Confirmación</div>
      </div>
    </div>

    <% if (err != null && !err.isEmpty()) { %>
      <div class="glassx p-4 mb-4" style="border-color:rgba(255,100,120,.35);background:rgba(255,100,120,.08)">
        <b>Error:</b> <%= err %>
      </div>
    <% } %>

    <div class="grid md:grid-cols-3 gap-6">
      <!-- IZQ: formulario -->
      <section class="md:col-span-2 glassx p-6">
        <h1 class="text-2xl font-extrabold mb-1">Pagar entrada</h1>
        <p class="muted mb-4"><b><%= ev.getTitle() %></b> · Cantidad: <b><%= qty %></b> · Total: <b><%= COP.format(total) %></b></p>

        <!-- Método de pago -->
        <div class="mb-4">
          <label class="block text-sm text-white/80 mb-1">Método de pago</label>
          <div class="pm-wrap" id="pmGrid" role="radiogroup" aria-label="Método de pago">
            <label class="pm active"><input type="radio" name="pm" value="VISA" checked>💳 Visa</label>
            <label class="pm"><input type="radio" name="pm" value="MASTERCARD">💳 MasterCard</label>
            <label class="pm"><input type="radio" name="pm" value="PSE">🏦 PSE</label>
            <label class="pm"><input type="radio" name="pm" value="NEQUI">📱 Nequi</label>
          </div>
        </div>

        <form action="<%= request.getContextPath() %>/Control/ct_pago_simulado.jsp" method="post" class="space-y-4" id="payForm" novalidate>
          <!-- Hidden essentials -->
          <input type="hidden" name="eventId" value="<%= eventId %>">
          <input type="hidden" name="qty"     value="<%= qty %>">
          <input type="hidden" name="amount"  value="<%= total %>">
          <input type="hidden" name="paymentMethod" id="paymentMethod" value="VISA">
          <!-- Página de retorno si hay error -->
          <input type="hidden" name="back" value="/Vista/PagoSimulado.jsp">

          <div class="field">
            <label class="block text-sm text-white/80 mb-1">Titular</label>
            <input required name="holder" autocomplete="cc-name" class="input" placeholder="Nombres y apellidos">
            <div class="error">Ingresa el nombre del titular.</div>
          </div>

          <!-- Campos tarjeta -->
          <div id="cardFields">
            <div class="grid md:grid-cols-2 gap-4">
              <div class="field">
                <label class="block text-sm text-white/80 mb-1">Número de tarjeta</label>
                <input required id="card" name="card" inputmode="numeric" autocomplete="cc-number"
                       maxlength="19" placeholder="4111 1111 1111 1111" class="input">
                <div class="error">Número inválido (Luhn). Si termina en 0000 simulamos error.</div>
              </div>

              <div class="field">
                <label class="block text-sm text-white/80 mb-1">CVV</label>
                <input required id="cvv" name="cvv" inputmode="numeric" autocomplete="cc-csc"
                       pattern="\\d{3,4}" maxlength="4" placeholder="123" class="input">
                <div class="error">CVV inválido.</div>
              </div>
            </div>

            <div class="grid md:grid-cols-2 gap-4">
              <div class="field">
                <label class="block text-sm text-white/80 mb-1">Vencimiento (MM/AA)</label>
                <input id="exp" name="exp" type="text" inputmode="numeric" autocomplete="cc-exp"
                       maxlength="5" pattern="(?:0[1-9]|1[0-2])\\/\\d{2}" title="Formato MM/AA (ej: 08/28)"
                       placeholder="MM/AA" required class="input" />
                <div class="error">Fecha inválida (MM/AA).</div>
              </div>

              <div>
                <label class="block text-sm text-white/80 mb-1">Documento (opcional)</label>
                <input name="doc" inputmode="numeric" placeholder="CC / NIT" class="input">
              </div>
            </div>
          </div>

          <label class="inline-flex items-center gap-2 text-sm">
            <input id="chkTerms" type="checkbox" class="accent-current">
            Acepto los <a href="#" class="underline">Términos</a> y la <a href="#" class="underline">Política de datos</a>.
          </label>

          <button id="btnPay" class="w-full btn-primary ripple opacity-50 pointer-events-none" type="submit">
            Pagar <%= COP.format(total) %>
          </button>
        </form>

        <div class="divider"></div>

        <div class="grid md:grid-cols-3 gap-3">
          <div class="glassx p-3 text-center">🔒 Conexión segura TLS 1.2</div>
          <div class="glassx p-3 text-center">🧾 Recibo y factura por correo</div>
          <div class="glassx p-3 text-center">🛟 Soporte en vivo</div>
        </div>

        <div class="mt-4 text-sm">
          ¿Problemas con el pago? <a class="underline" href="<%= request.getContextPath() %>/Vista/Checkout.jsp?eventId=<%= eventId %>&qty=<%= qty %>">volver a resumen</a>.
        </div>
      </section>

      <!-- DER: resumen -->
      <aside class="glassx p-6 h-fit sticky">
        <h3 class="font-bold text-lg mb-3">Resumen</h3>
        <ul class="text-white/80 space-y-1">
          <li class="flex justify-between"><span>Evento</span><span class="text-right"><%= ev.getTitle() %></span></li>
          <li class="flex justify-between"><span>Precio unitario</span><span><%= COP.format(unit) %></span></li>
          <li class="flex justify-between"><span>Cantidad</span><span><%= qty %></span></li>
          <li class="flex justify-between"><span>Total</span><span class="font-extrabold"><%= COP.format(total) %></span></li>
        </ul>
        <div class="divider"></div>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center mb-2"
           href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= eventId %>">Ver detalles</a>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 block text-center"
           href="<%= request.getContextPath() %>/Vista/ExplorarEventos.jsp">Seguir explorando</a>
      </aside>
    </div>

    <div class="grid sm:grid-cols-3 gap-4 mt-8">
      <div class="glassx p-4 text-center">🔐 Pagos cifrados</div>
      <div class="glassx p-4 text-center">🧩 Prevención de fraude activa</div>
      <div class="glassx p-4 text-center">💬 Respuesta promedio &lt; 2h</div>
    </div>
  </main>

  <!-- MODAL PSE/NEQUI -->
  <div id="pmModal" class="modal" role="dialog" aria-modal="true" aria-labelledby="pmTitle" aria-describedby="pmDesc">
    <div class="backdrop"></div>
    <div class="content">
      <div class="flex items-start justify-between gap-3">
        <div>
          <div class="chip" id="pmChip">Método</div>
          <h3 id="pmTitle" class="text-xl font-extrabold mt-2">Pago alterno</h3>
          <p id="pmDesc" class="text-white/70 mt-1">Sigue los pasos para completar tu pago.</p>
        </div>
        <button id="pmClose" class="px-3 py-1 rounded-lg border border-white/20 hover:border-white/35">✕</button>
      </div>

      <div class="divider"></div>

      <ol id="pmSteps" class="list-decimal pl-5 space-y-2 text-white/80"></ol>

      <div class="mt-4 flex items-center justify-end gap-2">
        <button id="pmCancel" class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30">Cancelar</button>
        <a id="pmContinue" class="btn-primary px-5 py-2 rounded-xl" href="#">Continuar</a>
      </div>
    </div>
  </div>

  <footer class="border-t border-white/10">
    <div class="max-w-6xl mx-auto px-5 py-6 flex flex-col sm:flex-row items-center justify-between text-white/70">
      <div class="font-extrabold flex items-center gap-2">Livepass <span class="text-aqua">Buga</span></div>
      <div>© <%= java.time.Year.now() %> Livepass Buga</div>
    </div>
  </footer>

  <script>
    // UI método de pago + mostrar/ocultar campos y modal para PSE/Nequi (simuladores)
    (function(){
      const grid = document.getElementById('pmGrid');
      const out  = document.getElementById('paymentMethod');
      const cardFields = document.getElementById('cardFields');

      // modal
      const modal = document.getElementById('pmModal');
      const pmChip = document.getElementById('pmChip');
      const pmTitle = document.getElementById('pmTitle');
      const pmDesc  = document.getElementById('pmDesc');
      const pmSteps = document.getElementById('pmSteps');
      const pmContinue = document.getElementById('pmContinue');
      const closeBtns = [document.getElementById('pmClose'), document.getElementById('pmCancel'), modal.querySelector('.backdrop')];

      // campos tarjeta
      const card = document.getElementById('card');
      const cvv  = document.getElementById('cvv');
      const exp  = document.getElementById('exp');

      const alreadyShown = {};

      function simulatorURL(method){
        const base = '<%= request.getContextPath() %>/Vista/' + (method==='PSE' ? 'PSE_Simulado.jsp' : 'Nequi_Simulado.jsp');
        const qs = `?eventId=<%= eventId %>&qty=<%= qty %>&amount=<%= total %>`;
        return base + qs;
      }

      function setModalFor(method){
        pmChip.textContent  = method==='PSE' ? '🏦 PSE' : '📱 Nequi';
        pmTitle.textContent = method==='PSE' ? 'Pago con PSE' : 'Pago con Nequi';
        pmDesc.textContent  = method==='PSE'
          ? 'Serás redirigido al banco para autorizar el débito desde tu cuenta.'
          : 'Abriremos Nequi para que apruebes el pago desde tu celular.';
        pmSteps.innerHTML = '';
        (method==='PSE'
          ? ['Selecciona tu banco y autentícate.','Autoriza el pago por el total indicado.','Volverás automáticamente con la confirmación.']
          : ['Confirma el número de tu cuenta.','Aprueba el cobro en la app Nequi.','Regresa para ver la confirmación.']
        ).forEach(t=>{ const li=document.createElement('li'); li.textContent=t; pmSteps.appendChild(li); });

        pmContinue.href = simulatorURL(method);
      }

      function showModal(method){
        setModalFor(method);
        modal.classList.add('show');
        document.body.style.overflow='hidden';
      }
      function hideModal(){
        modal.classList.remove('show');
        document.body.style.overflow='';
      }
      closeBtns.forEach(b=> b && b.addEventListener('click', hideModal));
      document.addEventListener('keydown', e=>{ if(e.key==='Escape' && modal.classList.contains('show')) hideModal(); });

      function toggleCardFields(isCard){
        cardFields.style.display = isCard ? '' : 'none';
        [card, cvv, exp].forEach(el=>{
          if (!el) return;
          if (isCard) el.setAttribute('required','required');
          else        el.removeAttribute('required');
        });
      }

      function sync(){
        const m = out.value;
        const isCard = (m==='VISA' || m==='MASTERCARD');
        toggleCardFields(isCard);
        if (!isCard && !alreadyShown[m]) { alreadyShown[m]=true; showModal(m); }
      }

      grid.querySelectorAll('.pm').forEach(el=>{
        el.addEventListener('click', ()=>{
          grid.querySelectorAll('.pm').forEach(i=>i.classList.remove('active'));
          el.classList.add('active');
          const r = el.querySelector('input[type=radio]');
          if (r) { r.checked = true; out.value = r.value; sync(); }
        });
      });

      document.getElementById('btnPay').addEventListener('click', function(e){
        const m = out.value;
        if (m==='PSE' || m==='NEQUI') {
          if (alreadyShown[m]) window.location.href = simulatorURL(m);
          else { alreadyShown[m]=true; showModal(m); }
          e.preventDefault();
        }
      });

      sync();
    })();

    // Formateo tarjeta (caret estable)
    (function(){
      const input = document.getElementById('card');
      if (!input) return;
      function formatAndKeepCaret(){
        const old = input.value;
        const oldPos = input.selectionStart || 0;
        const digitsLeft = (old.slice(0, oldPos).match(/\d/g)||[]).length;
        const raw = old.replace(/\D/g,'').slice(0,16);
        const groups = raw.match(/.{1,4}/g) || [];
        const formatted = groups.join(' ');
        input.value = formatted;
        let pos=0, seen=0;
        while (pos<formatted.length && seen<digitsLeft){ if (/\d/.test(formatted[pos])) seen++; pos++; }
        input.setSelectionRange(pos,pos);
      }
      input.addEventListener('input', formatAndKeepCaret);
    })();

    // Exp (MM/AA)
    (function(){
      const exp = document.getElementById('exp');
      if (!exp) return;
      function formatExp(){
        const old = exp.value;
        const oldPos = exp.selectionStart || 0;
        const digitsLeft = (old.slice(0, oldPos).replace(/\D/g,'').length);
        let raw = old.replace(/\D/g,'').slice(0,4);
        if (raw.length>=1){
          let mm = parseInt(raw.slice(0,2)||'0',10);
          if (!isNaN(mm)){ if(mm<=0) mm=1; if(mm>12) mm=12; raw = String(mm).padStart(2,'0') + raw.slice(2); }
        }
        let formatted = raw.length>2 ? raw.slice(0,2)+'/'+raw.slice(2) : raw;
        exp.value = formatted;
        let pos=0, seen=0;
        while (pos<formatted.length && seen<digitsLeft){ if (/\d/.test(formatted[pos])) seen++; pos++; }
        if (pos===2 && formatted[pos]==='/') pos++;
        exp.setSelectionRange(pos,pos);
      }
      exp.addEventListener('input', formatExp);
      exp.addEventListener('blur', ()=>{ const r = exp.value.replace(/\D/g,''); if (r.length===1) exp.value = '0'+r+'/'; });
    })();

    // Validaciones + habilitar botón
    (function(){
      const form = document.getElementById('payForm');
      const btn  = document.getElementById('btnPay');
      const chk  = document.getElementById('chkTerms');
      const pm   = document.getElementById('paymentMethod');
      const card = document.getElementById('card');
      const cvv  = document.getElementById('cvv');
      const exp  = document.getElementById('exp');

      function luhn(num){ let s=0,alt=false; for(let i=num.length-1;i>=0;i--){let n=parseInt(num.charAt(i),10); if(alt){n*=2;if(n>9)n-=9} s+=n; alt=!alt;} return s%10===0; }

      function validate(){
        let ok = true;
        const holderField = form.querySelector('[name="holder"]').closest('.field');
        if (!form.holder.value.trim()){ holderField.classList.add('invalid'); ok=false; } else holderField.classList.remove('invalid');

        const usingCard = (pm.value==='VISA' || pm.value==='MASTERCARD');
        if (usingCard){
          const raw = card.value.replace(/\D/g,'');
          const cardField = card.closest('.field');
          if (raw.length<13 || !luhn(raw)){ cardField.classList.add('invalid'); ok=false; } else cardField.classList.remove('invalid');

          const cvvField = cvv.closest('.field');
          if (!/^\d{3,4}$/.test(cvv.value)){ cvvField.classList.add('invalid'); ok=false; } else cvvField.classList.remove('invalid');

          const expField = exp.closest('.field');
          const m = exp.value.match(/^(\d{2})\/(\d{2})$/);
          if (!m){ expField.classList.add('invalid'); ok=false; }
          else {
            const mm=parseInt(m[1],10), yy=parseInt('20'+m[2],10);
            const now=new Date(), endMonth=new Date(yy, mm);
            if (endMonth<=now){ expField.classList.add('invalid'); ok=false; } else expField.classList.remove('invalid');
          }
        }

        if (!chk.checked) ok=false;

        if (ok){ btn.classList.remove('opacity-50','pointer-events-none'); }
        else    { btn.classList.add   ('opacity-50','pointer-events-none'); }

        return ok;
      }

      form.addEventListener('input', validate);
      chk.addEventListener('change', validate);
      document.getElementById('pmGrid').addEventListener('click', validate);
      form.addEventListener('submit', function(e){ if(!validate()) e.preventDefault(); });
      validate();
    })();

    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(btn=>{
        btn.addEventListener('click', function(e){
          const r=this.getBoundingClientRect(), s=document.createElement('span'), z=Math.max(r.width,r.height);
          s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
          this.appendChild(s); setTimeout(()=>s.remove(),600);
        });
      });
    })();
  </script>
</body>
</html>
