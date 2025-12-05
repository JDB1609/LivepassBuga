<!DOCTYPE html>
<html>
<head>
    <title>Soporte</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[#0A0C14] text-white flex justify-center items-center h-screen">

    <form action="SoporteServlet" method="post" 
          class="bg-[#11131A] p-8 rounded-xl w-[400px] space-y-4 shadow-xl">

        <h2 class="text-2xl font-bold mb-4">Centro de Soporte</h2>

        <input type="text" name="nombre" placeholder="Tu nombre"
               class="w-full p-2 rounded bg-[#1A1D24]" required>

        <input type="email" name="email" placeholder="Correo electrónico"
               class="w-full p-2 rounded bg-[#1A1D24]" required>

        <textarea name="mensaje" placeholder="Escribe tu mensaje"
                  class="w-full p-2 rounded bg-[#1A1D24] h-32" required></textarea>

        <button type="submit" 
                class="bg-[#5469D5] w-full py-2 rounded font-bold hover:bg-[#4053b3]">
            Enviar mensaje
        </button>
    </form>

</body>
</html>

