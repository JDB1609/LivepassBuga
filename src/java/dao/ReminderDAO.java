/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import utils.Conexion;
import utils.Event;
import utils.Reminder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;



public class ReminderDAO {
    
    private EventDAO eventDAO;
    public ReminderDAO() {
        this.eventDAO = new EventDAO(); // inicializamos el DAO de eventos
    }

    // Crear recordatorio automático al comprar: recibe el email del usuario y el id del evento
    public void crearRecordatorioCompra(String userEmail, int idEvento) {
        Event event = eventDAO.obtenerPorId(idEvento); // ajusta el nombre si tu EventDAO usa findById/getById
        if (event == null) {
            throw new RuntimeException("Evento no encontrado: id=" + idEvento);
        }
        LocalDateTime eventDateTime = event.getDateTime();
        if (eventDateTime == null) {
            throw new RuntimeException("El evento id=" + idEvento + " no tiene fecha/hora (dateTime) definida");
        }

        // Un día antes del evento. Opcional: fijar hora de envío (ej. 09:00 del día anterior)
        LocalDateTime reminderDateTime = eventDateTime.minusDays(1);
        Timestamp shippingTs = Timestamp.valueOf(reminderDateTime);

        // Mensaje simple (personaliza a tu gusto)
        String message = "Recordatorio: " + event.getTitle() + " es mañana (" + event.getDate() + ").";

        String sql = "INSERT INTO reminders (user_email, message, shipping_date, sent) VALUES (?, ?, ?, 0)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userEmail);
            ps.setString(2, message);
            ps.setTimestamp(3, shippingTs);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error creando recordatorio: " + e.getMessage(), e);
        }
    }

    
    // Obtener recordatorios pendientes
    public List<Reminder> getPendingReminders() {
        List<Reminder> list = new ArrayList<>();
        String sql = "SELECT id, user_email, message, shipping_date, sent " +
                     "FROM reminders " +
                     "WHERE sent = 0 AND shipping_date <= NOW()";

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Reminder r = new Reminder(
                    rs.getInt("id"),
                    rs.getString("user_email"),
                    rs.getString("message"),
                    rs.getTimestamp("shipping_date"),
                    rs.getBoolean("sent")
                );
                list.add(r);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error obteniendo recordatorios pendientes: " + e.getMessage(), e);
        }
        return list;
    }

    // Marcar como enviado
    public void markAsSent(int id) {
        String sql = "UPDATE reminders SET sent = 1 WHERE id = ?";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error marcando recordatorio como enviado: " + e.getMessage(), e);
        }
    }


    // Insertar manualmente un recordatorio
    public void insertReminder(String email, String message, java.sql.Timestamp shippingDate) {
        String sql = "INSERT INTO reminders (user_email, message, shipping_date, sent) VALUES (?, ?, ?, 0)";
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, message);
            ps.setTimestamp(3, shippingDate);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error insertando recordatorio: " + e.getMessage(), e);
        }
    }

    // Obtener todos los recordatorios
    public List<Reminder> getAllReminders() {
        List<Reminder> list = new ArrayList<>();
        String sql = "SELECT id, user_email, message, shipping_date, sent FROM reminders";

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Reminder r = new Reminder(
                    rs.getInt("id"),
                    rs.getString("user_email"),
                    rs.getString("message"),
                    rs.getTimestamp("shipping_date"),
                    rs.getBoolean("sent")
                );
                list.add(r);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error obteniendo todos los recordatorios: " + e.getMessage(), e);
        }
        return list;
    }
}
