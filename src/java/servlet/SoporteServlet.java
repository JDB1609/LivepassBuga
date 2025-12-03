package servlet;

import dao.SoporteDAO;
import utils.SoporteMensaje;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/Soporte")
public class SoporteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String nombre = request.getParameter("nombre");
        String email = request.getParameter("email");
        String mensaje = request.getParameter("mensaje");
        
        // Validación simple
        if (nombre == null || email == null || mensaje == null ||
            nombre.isEmpty() || email.isEmpty() || mensaje.isEmpty()) {

            response.getWriter().write(
                    "{\"status\":\"error\", \"msg\":\"Todos los campos son obligatorios\"}"
            );
            return;
        }

        SoporteMensaje sm = new SoporteMensaje(nombre, email, mensaje);
        SoporteDAO dao = new SoporteDAO();

        try {
            boolean ok = dao.guardar(sm);

            if (ok) {
                response.getWriter().write("{\"status\":\"ok\", \"msg\":\"Mensaje enviado correctamente\"}");
            } else {
                response.getWriter().write("{\"status\":\"error\", \"msg\":\"No se pudo guardar en la BD\"}");
            }

        } catch (Exception e) {
            // 👇 Captura el error real y lo devuelve al cliente
            String errorMsg = e.getMessage().replace("\"", "'"); // evita romper el JSON
            response.getWriter().write("{\"status\":\"error\", \"msg\":\"Error SQL: " + errorMsg + "\"}");
            e.printStackTrace(); // sigue mostrando en consola
        }

       
    }
}
