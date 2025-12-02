 /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import utils.SoporteMensaje;
import utils.Conexion;  
import java.sql.*;

public class SoporteDAO {

    private static final String INSERT = "INSERT INTO support (nombre, email, mensaje) VALUES (?, ?, ?)";

    public boolean guardar(SoporteMensaje mensaje) {

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(INSERT)) {

            // Seteamos parámetros
            ps.setString(1, mensaje.getNombre());
            ps.setString(2, mensaje.getEmail());
            ps.setString(3, mensaje.getMensaje());

            // Ejecutamos
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Error en SoporteDAO al guardar: " + e.getMessage());
            return false;
        }
    }
}


