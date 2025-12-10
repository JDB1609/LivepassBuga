/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import servicio.ReporteServicio;

@WebServlet("/reporte")
public class ReporteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String tabla = request.getParameter("tabla");
        ReporteServicio servicio = new ReporteServicio();

        try {
            if (tabla == null || tabla.isBlank()) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", "No se seleccionó ninguna tabla");
                response.sendRedirect(request.getContextPath() + "/Vista/Reportes.jsp");
                return;
            }

            List<Map<String,Object>> datos = servicio.obtenerDatos(tabla);

            if (datos == null || datos.isEmpty()) {
                HttpSession session = request.getSession();
                session.setAttribute("flashError", "La tabla está vacía");
                response.sendRedirect(request.getContextPath() + "/Vista/Reportes.jsp");
                return;
            }
            // Generar CSV
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", "attachment; filename=reporte_" + tabla + ".csv");

            try (PrintWriter outCsv = response.getWriter()) {
                servicio.generarCSV(datos, outCsv);
            }

        } catch (Exception e) {
            HttpSession session = request.getSession();
            session.setAttribute("flashError", "Error generando reporte: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/Vista/Reportes.jsp");
        }
    }
}

