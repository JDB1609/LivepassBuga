<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base_administrador.jspf" %>
  <title>Reportes — Livepass Buga</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/estilos.css">
</head>
<body>
  <%@ include file="../Includes/nav_base_administrador.jspf" %>

  <main class="relative px-6 py-10">
    <h1 class="titulo text-4xl font-bold mb-6">Reportes</h1>
    <p class="text-white/70 mb-8 text-center max-w-xl mx-auto">
      Selecciona la tabla que deseas exportar en formato CSV. Este archivo puede abrirse en Excel, Google Sheets o cualquier editor de texto plano.
    </p>

    <!-- Contenedor de alertas -->
    <div id="alertaError" class="hidden px-4 py-3 mb-4 rounded-lg bg-red-600 text-white font-semibold text-center"></div>

    <!-- Tarjeta -->
    <div class="card p-6 shadow-lg max-w-2xl mx-auto rounded-xl bg-[#1A1B26] text-white">
      <form action="<%= request.getContextPath() %>/reporte" method="get" class="space-y-6 text-center">

        <!-- Formato fijo -->
        <div class="w-full max-w-md mx-auto px-4 py-3 rounded-xl bg-[#1A1B26] border border-[#684DFF]">
          <span class="font-semibold">Tipo de formato:</span> CSV (texto plano)
          <input type="hidden" name="formato" value="csv" />
        </div>
        <!-- Selector de tabla -->
        <div class="relative inline-block w-full max-w-md mx-auto" id="selectTabla">
          <button type="button" id="tablaBtn" class="w-full px-4 py-3 rounded-xl bg-[#1A1B26] border border-[#684DFF] text-left flex justify-between items-center">
            <span id="tablaTexto">Tabla a exportar</span>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>
          </button>
          <ul id="tablaOpciones" class="absolute mt-2 w-full bg-[#1A1B26] rounded-xl shadow-lg hidden z-10">
            <li class="px-4 py-2 hover:bg-[#684DFF]" data-value="users">Usuarios</li>
            <li class="px-4 py-2 hover:bg-[#684DFF]" data-value="support">Soporte</li>
          </ul>
          <input type="hidden" name="tabla" id="tablaInput" value="">
        </div>
        <p id="tablaSeleccionada" class="text-sm text-white/60 mt-2"></p>

        <!-- Botones -->
        <div class="flex gap-4 justify-center">
          <a href=BackofficeAdministrador.jsp class="px-6 py-3 rounded-xl border font-semibold" style="border-color:#684DFF; color:#684DFF;">Regresar</a>
          <button type="submit" class="px-6 py-3 rounded-xl font-semibold text-white" style="background-color:#684DFF;">Descargar reporte</button>
        </div>
      </form>
    </div>
  </main>

<script>
    // Selector de tabla
    const btnTabla = document.getElementById('tablaBtn');
    const opcionesTabla = document.getElementById('tablaOpciones');
    const inputTabla = document.getElementById('tablaInput');
    const textoTabla = document.getElementById('tablaTexto');
    const tablaSeleccionada = document.getElementById('tablaSeleccionada');

    btnTabla.addEventListener('click', () => opcionesTabla.classList.toggle('hidden'));
    opcionesTabla.querySelectorAll('li').forEach(opcion => {
      opcion.addEventListener('click', () => {
        textoTabla.textContent = opcion.textContent;
        inputTabla.value = opcion.getAttribute('data-value');
        tablaSeleccionada.textContent = "Tabla seleccionada: " + opcion.textContent;
        opcionesTabla.classList.add('hidden');
      });
    });
    document.addEventListener('click', (e) => {
      if (!document.getElementById('selectTabla').contains(e.target)) opcionesTabla.classList.add('hidden');
    });
// Mostrar error con animación
    function mostrarError(mensaje) {
      const alerta = document.getElementById('alertaError');
      alerta.textContent = mensaje;
      alerta.classList.remove('hidden');
      alerta.style.opacity = '1';
      setTimeout(() => {
        alerta.style.opacity = '0';
        setTimeout(() => alerta.classList.add('hidden'), 300);
      }, 5000);
    }

    window.addEventListener('DOMContentLoaded', () => {
      <% String flash = (String) session.getAttribute("flashError"); if (flash != null) { %>
        mostrarError("<%= flash %>");
        <% session.removeAttribute("flashError"); %>
      <% } %>
    });
  </script>
</body>
</html>
