/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package servicio;

import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import utils.Conexion;
import dao.SoporteDAO;
import dao.UserDAO;
import dao.EventDAO;

public class ReporteServicio {
    public List<Map<String,Object>> obtenerDatos(String tabla) throws Exception {
        switch (tabla) {
            case "users":
                return new UserDAO().obtenerUsuarios();
            case "reminders":
                //return new RecordatorioDAO().obtenerRecordatorios();
            case "support":
                return new SoporteDAO().obtenerSoportes();
            //case "events":
                //return new EvetDa().obtenerSoportes();
            default:
                throw new IllegalArgumentException("Tabla no soportada: " + tabla);
        }
    }


    public void generarCSV(List<Map<String,Object>> datos, PrintWriter out) {
        if (datos.isEmpty()) return;

        // Escribir encabezados
        Set<String> columnas = datos.get(0).keySet();
        out.println(String.join(",", columnas));

        // Escribir filas
        for (Map<String,Object> fila : datos) {
            List<String> valores = new ArrayList<>();
            for (String col : columnas) {
                Object val = fila.get(col);
                if (val == null) {
                    valores.add("");
                } else {
                    // Escapar comas para no romper el CSV
                    String texto = val.toString().replace(",", " ");
                    valores.add(texto);
                }
            }
            out.println(String.join(",", valores));
        }
    }
}

