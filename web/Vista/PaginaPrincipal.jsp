<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>LivePassBuga - Página Principal</title>

    <!-- TAILWIND -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Archivos CSS -->
    <link rel="stylesheet" href="../Styles/estilos.css">
    
    <!-- Icono de buscar -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

</head>

<body class="bg-[#0A0C14] text-white">

<!-- NAVBAR -->
<nav class="w-full flex items-center justify-between px-6 py-3 bg-[#0A0C14] border-b border-[#1F2230]">

    <!-- HAMBURGUESA SOLO PARA PLATAFORMAS MOVILES -->
    <div class="hamburger cursor-pointer mr-4" onclick="toggleMenu()">
        <span></span>
        <span></span>
        <span></span>
    </div>

    <!-- LOGO -->
    <a href="PaginaPrincipal.jsp" class="flex items-center">
        <img src="../Imagenes/Livepass Buga Logo.png" alt="LivePass" class="h-10">
    </a>

    <!-- NAV LINKS (DESKTOP) -->
    <ul class="hidden md:flex gap-6 ml-auto text-sm">
        <li><a href="PaginaPrincipal.jsp" class="hover:text-[#5469D5]">Inicio</a></li>
        <li><a href="ExplorarEventos.jsp" class="hover:text-[#5469D5]">Buscar eventos</a></li>
        <li><a href="Contacto.jsp" class="hover:text-[#5469D5]">Contacto</a></li>
    </ul>

    <!-- BOTONES DERECHA -->
    <div class="hidden md:flex gap-4 ml-6">
        <a href="Login.jsp" class="btn-secondary px-4 py-1 rounded-lg block text-center">Ingresar</a>
        <a href="Registro.jsp" class="btn-primary px-4 py-1 rounded-lg block text-center">Registrarse</a>
    </div>
</nav>

<!-- MENÚ LATERAL -->
<div id="sideMenu" 
     class="side-menu fixed top-0 left-0 w-64 h-full bg-[#141622] shadow-xl 
            transform -translate-x-full transition-transform duration-300 z-50">

    <div class="p-5 border-b border-[#1F2230]">
        <h3 class="font-bold text-lg">Menú</h3>
    </div>

    <ul class="p-5 space-y-4 text-sm">
        <li><a href="PaginaPrincipal.jsp" class="hover:text-[#5469D5]">Inicio</a></li>
        <li><a href="ExplorarEventos.jsp" class="hover:text-[#5469D5]">Buscar eventos</a></li>
        <li><a href="Contacto.jsp" class="hover:text-[#5469D5]">Contacto</a></li>
        <li class="pt-4 border-t border-[#1F2230]">
            <a href="Login.jsp" class="hover:text-[#5469D5]">Ingresar</a>
        </li>
        <li>
            <a href="Registro.jsp" class="hover:text-[#5469D5]">Registrarse</a>
        </li>
    </ul>
</div>

<!-- ===========================
     HERO SECTION
=========================== -->
<section class="relative w-full h-[450px] mt-2">
    <img src="../Imagenes/ejemplo.png" class="w-full h-full object-cover opacity-60">
    <img src="../Imagenes/Banner.jpg"  class="absolute top-0 left-0 w-full h-[450px] Sobject-cover opacity-90 pointer-events-none">

    <div class="absolute top-20 left-10">
        <p class="text-sm" style="color:#00E0C6;">Plataforma moderna</p>

        <h1 class="text-4xl font-bold w-[500px] leading-tight titulo">
            Compra, gestiona y valida <span style="color:#5469D5">tickets con QR</span>
        </h1>

        <p class="w-[450px] mt-2">
            Experiencia sin filas, validación instantánea y seguridad total para eventos.
        </p>

         <!-- BARRA DE BÚSQUEDA BIEN UBICADA -->
        <div class="mt-6">
            <div class="flex items-center bg-white rounded-md shadow-md px-3 py-2 w-[420px]">
                <span class="material-icons text-gray-500 mr-2">search</span>
                <input 
                    type="text" 
                    placeholder="Buscar eventos"
                    class="w-full outline-none text-sm"
                    style="color: #6D6E6E;"  <!-- color del texto al escribir en el buscador -->
                />
            </div>
        </div>
    </div>

    <!-- Panel lateral -->
    <div class="absolute right-10 top-8 w-[300px] p-4 rounded-xl shadow-xl card">
        <img src="../Imagen/ejemplo.png" class="rounded-lg w-full h-[180px] object-cover">
        <h2 class="mt-3 text-lg font-bold titulo">Próximo evento</h2>
        <p class="text-sm">Nombre del evento</p>
        <p class="mt-1 font-semibold" style="color:#5469D5">$80.000 - $350.000</p>

        <button class="btn-primary w-full mt-3 py-2 rounded-lg">Reservar</button>
        <button class="w-full mt-2 text-sm btn-secondary py-2 rounded-lg">Ver Detalles</button>
    </div>
</section>

<!-- ===========================
     EVENTOS DESTACADOS
=========================== -->
<section class="px-10 mt-20">
    <h2 class="text-2xl font-bold titulo">Eventos destacados</h2>
    <p class="text-sm mb-6">Lo más popular de la semana</p>

    <div class="grid grid-cols-4 gap-8">

        <!-- EVENTO CARD 1 -->
        <div class="bg-[#1A1B26] shadow-lg rounded-xl p-3 transition hover:-translate-y-1">
            <img src="../Imagenes/evento1.jpg" class="rounded-lg w-full h-[200px] object-cover">
            <p class="font-bold titulo mt-3">Concierto de Rock</p>
            <p class="text-sm text-gray-300">12 Nov 2025 • Buga</p>
            <p class="text-sm mt-1 font-semibold" style="color:#5469D5">$40.000 - $120.000</p>

            <button class="btn-primary w-full mt-3 py-2 rounded-lg">Comprar</button>
            <button class="btn-secondary w-full mt-2 text-sm py-2 rounded-lg">Detalles</button>
        </div>

        <!-- EVENTO CARD 2 -->
        <div class="bg-[#1A1B26] shadow-lg rounded-xl p-3 transition hover:-translate-y-1">
            <img src="../Imagenes/evento2.jpg" class="rounded-lg w-full h-[200px] object-cover">
            <p class="font-bold titulo mt-3">Clásicos del Pop</p>
            <p class="text-sm text-gray-300">30 Nov 2025 • Cali</p>
            <p class="text-sm mt-1 font-semibold" style="color:#5469D5">$55.000 - $150.000</p>

            <button class="btn-primary w-full mt-3 py-2 rounded-lg">Comprar</button>
            <button class="btn-secondary w-full mt-2 text-sm py-2 rounded-lg">Detalles</button>
        </div>

        <!-- EVENTO CARD 3 -->
        <div class="bg-[#1A1B26] shadow-lg rounded-xl p-3 transition hover:-translate-y-1">
            <img src="../Imagenes/evento3.jpg" class="rounded-lg w-full h-[200px] object-cover">
            <p class="font-bold titulo mt-3">Festival Electrónico</p>
            <p class="text-sm text-gray-300">18 Dic 2025 • Palmira</p>
            <p class="text-sm mt-1 font-semibold" style="color:#5469D5">$70.000 - $200.000</p>

            <button class="btn-primary w-full mt-3 py-2 rounded-lg">Comprar</button>
            <button class="btn-secondary w-full mt-2 text-sm py-2 rounded-lg">Detalles</button>
        </div>

        <!-- EVENTO CARD 4 -->
        <div class="bg-[#1A1B26] shadow-lg rounded-xl p-3 transition hover:-translate-y-1">
            <img src="../Imagenes/evento4.jpg" class="rounded-lg w-full h-[200px] object-cover">
            <p class="font-bold titulo mt-3">Obra de Teatro</p>
            <p class="text-sm text-gray-300">05 Ene 2026 • Buga</p>
            <p class="text-sm mt-1 font-semibold" style="color:#5469D5">$30.000 - $80.000</p>

            <button class="btn-primary w-full mt-3 py-2 rounded-lg">Comprar</button>
            <button class="btn-secondary w-full mt-2 text-sm py-2 rounded-lg">Detalles</button>
        </div>

    </div>
</section>


<!-- ===========================
     CATEGORÍAS POPULARES
=========================== -->
<section class="px-10 mt-20">
    <h2 class="text-2xl font-bold titulo">Categorías populares</h2>
    <p class="text-sm mb-6">Explora las diversas categorías</p>

    <div class="grid grid-cols-3 gap-8">

        <!-- Deportes -->
        <div class="card-categoria p-6 rounded-xl flex gap-4">
            <img src="../Iconos/trofeo.png" class="icono-evento">
            <div>
                <p class="titulo font-bold">Deportes</p>
                <p class="text-sm">Partidos y torneos.</p>
            </div>
        </div>

        <!-- Música -->
        <div class="card-categoria p-6 rounded-xl flex gap-4">
            <img src="../Iconos/musica.png" class="icono-evento">
            <div>
                <p class="titulo font-bold">Música</p>
                <p class="text-sm">Conciertos y festivales.</p>
            </div>
        </div>

        <!-- Conferencias -->
        <div class="card-categoria p-6 rounded-xl flex gap-4">
            <img src="../Iconos/microfono.png" class="icono-evento">
            <div>
                <p class="titulo font-bold">Conferencias</p>
                <p class="text-sm">Tech, negocios y tendencias.</p>
            </div>
        </div>

    </div>
</section>



<!-- ===========================
     CARACTERÍSTICAS LIVEPASS
=========================== -->
<section class="px-10 mt-24">
    <h2 class="text-2xl font-bold titulo">Características de LivePass Buga</h2>
    <p class="text-sm mb-10">Miles de personas confían en nosotros para vivir las mejores experiencias</p>

    <div class="grid grid-cols-4 gap-6">

        <!-- Compra Segura -->
        <div class="bg-[#1A1B26] p-6 rounded-xl text-center shadow-lg">
            <img src="../Iconos/Seguridad.png" class="mx-auto w-10 mb-3">
            <p class="font-bold titulo">Compra Segura</p>
            <p class="text-sm">Tus datos protegidos con encriptación de nivel bancario.</p>
        </div>

        <!-- Tickets Digitales -->
        <div class="bg-[#1A1B26] p-6 rounded-xl text-center shadow-lg">
            <img src="../Iconos/Celular.png" class="mx-auto w-10 mb-3">
            <p class="font-bold titulo">Tickets Digitales</p>
            <p class="text-sm">Accede a tus tickets desde cualquier dispositivo móvil.</p>
        </div>

        <!-- Compra Instantánea -->
        <div class="bg-[#1A1B26] p-6 rounded-xl text-center shadow-lg">
            <img src="../Iconos/Rayo.png" class="mx-auto w-10 mb-3">
            <p class="font-bold titulo">Compra Instantánea</p>
            <p class="text-sm">Confirmación inmediata y acceso rápido a los eventos.</p>
        </div>

        <!-- Pagos Flexibles -->
        <div class="bg-[#1A1B26] p-6 rounded-xl text-center shadow-lg">
            <img src="../Iconos/Cartera.png" class="mx-auto w-10 mb-3">
            <p class="font-bold titulo">Pagos Flexibles</p>
            <p class="text-sm">Múltiples métodos y cuotas sin intereses.</p>
        </div>

    </div>
</section>

<!-- ===========================
            FOOTER
=========================== -->
<footer class="mt-24 px-14 py-16 bg-[#0A0C14] border-t border-[#1F2230]">

    <div class="grid grid-cols-4 gap-12">

        <!-- LOGO + DESCRIPCIÓN -->
        <div>
            <div class="flex items-center gap-2 mb-4">
                <h2 class="titulo text-xl font-bold">LivePassBuga</h2>
            </div>

            <p class="text-sm text-gray-400 mb-5">
                Tu plataforma de confianza para comprar tickets<br>
                de los mejores eventos.
            </p>

            <!-- ICONOS REDES -->
            <div class="flex gap-4 mt-3">
                <img src="../Iconos/facebook.png"  class="w-6 cursor-pointer hover:opacity-80">
                <img src="../Iconos/twitter.png"   class="w-6 cursor-pointer hover:opacity-80">
                <img src="../Iconos/instagram.png" class="w-6 cursor-pointer hover:opacity-80">
                <img src="../Iconos/youtube.png"   class="w-6 cursor-pointer hover:opacity-80">
            </div>
        </div>

        <!-- CATEGORÍAS -->
        <div>
            <h3 class="titulo text-lg font-semibold mb-3">Categorías</h3>
            <ul class="space-y-2 text-gray-300 text-sm">
                <li>Conciertos</li>
                <li>Deportes</li>
                <li>Teatro</li>
                <li>Festivales</li>
                <li>Comedia</li>
            </ul>
        </div>

        <!-- AYUDA -->
        <div>
            <h3 class="titulo text-lg font-semibold mb-3">Ayuda</h3>
            <ul class="space-y-2 text-gray-300 text-sm">
                <li>Centro de ayuda</li>
                <li>Cómo comprar</li>
                <li>Términos y condiciones</li>
                <li>Política de privacidad</li>
                <li>Reembolsos</li>
            </ul>
        </div>

        <!-- CONTACTO -->
        <div>
            <h3 class="titulo text-lg font-semibold mb-3">Contacto</h3>

            <div class="flex items-center gap-3 mb-3">
                <img src="../Iconos/email.png" class="w-5">
                <p class="text-sm text-gray-300">info@Livepassbuga.com</p>
            </div>

            <div class="flex items-center gap-3 mb-3">
                <img src="../Iconos/telefono.png" class="w-5">
                <p class="text-sm text-gray-300">+57 318 900 1234</p>
            </div>

            <div class="flex items-start gap-3">
                <img src="../Iconos/mapa.png" class="w-5 mt-1">
                <p class="text-sm text-gray-300">
                    Calle Principal 123<br>
                    28001 Guadalajara de Buga, Colombia
                </p>
            </div>
        </div>

    </div>

    <!-- COPYRIGHT -->
    <div class="text-center text-gray-400 text-sm mt-10 pt-5 border-t border-[#1F2230]">
        © 2025 LivePass Todos los derechos reservados.
    </div>
</footer>



<!-- BOTÓN SOPORTE -->
<div id="btnSoporte"
     class="fixed bottom-6 right-6 bg-[#5469D5] text-white 
            w-14 h-14 rounded-full shadow-xl flex items-center justify-center 
            cursor-pointer hover:scale-110 transition"
     onclick="toggleSoporte()">
    <img src="../Iconos/soporte.png" class="w-7 h-7">
</div>

<!-- VENTANA SOPORTE -->
<div id="ventanaSoporte"
     class="fixed bottom-24 right-6 w-80 bg-[#1A1B26] text-white p-5 
            rounded-xl shadow-2xl hidden transition">

    <h3 class="text-lg font-semibold mb-3">Soporte</h3>

    <!-- 🔥 ACTION CORRECTO -->
    <form id="formSoporte" action="<%= request.getContextPath() + "/Soporte" %>" method="post" class="flex flex-col gap-3">

        <input type="text" name="nombre" placeholder="Tu nombre"
               class="bg-[#0A0C14] p-2 rounded text-sm" required>

        <input type="email" name="email" placeholder="Correo"
               class="bg-[#0A0C14] p-2 rounded text-sm" required>

        <textarea name="mensaje" placeholder="Describe tu problema"
                  class="bg-[#0A0C14] p-2 rounded text-sm h-20 resize-none" required></textarea>

        <button type="submit" class="bg-[#5469D5] py-2 rounded font-semibold hover:opacity-90">
            Enviar
        </button>
    </form>

    <div id="mensajeRespuesta" class="mt-3"></div>
</div>

<!-- SCRIPT MOSTRAR/OCULTAR -->
<script>
function toggleSoporte() {
    document.getElementById("ventanaSoporte").classList.toggle("hidden");
}
</script>

<!-- SCRIPT ENVÍO AJAX -->
<script>
document.addEventListener("DOMContentLoaded", () => {
    const form = document.getElementById("formSoporte");

    form.addEventListener("submit", async function (e) {
        e.preventDefault();

        // Convertimos FormData a URLSearchParams
        const datos = new URLSearchParams(new FormData(form));

        try {
            const response = await fetch(form.action, {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: datos
            });

            const result = await response.json(); // el servlet devuelve JSON

            mostrarMensaje(result.status, result.msg);

            if (result.status === "ok") {
                form.reset();
            }

        } catch (error) {
            mostrarMensaje("error", "Hubo un error inesperado.");
        }
    });
});

function mostrarMensaje(tipo, texto) {
    const contenedor = document.getElementById("mensajeRespuesta");
    const color = tipo === "ok" ? "bg-green-600" : "bg-red-600";

    contenedor.innerHTML =
        '<div class="p-3 rounded text-white ' + color + '">' +
        texto +
        '</div>';

    setTimeout(() => {
        contenedor.innerHTML = "";
    }, 3500);
}
</script>






<script>
function toggleMenu() {
    const menu = document.getElementById("sideMenu");
    const burger = document.querySelector(".hamburger");
    menu.classList.toggle("-translate-x-full");
    burger.classList.toggle("active");
}
</script>



</body>
</html>

