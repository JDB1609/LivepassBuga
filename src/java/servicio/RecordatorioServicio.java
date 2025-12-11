/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package servicio;

import dao.ReminderDAO;
import java.util.List;
import utils.Reminder;
import utils.EmailSender;

public class RecordatorioServicio {
    public void checkAndSendReminders() {
        ReminderDAO dao = new ReminderDAO();
        List<Reminder> reminders = dao.getPendingReminders();

        for (Reminder reminder : reminders) {
            String email = reminder.getUserEmail();
            String subject = "Recordatorio de evento";
            String body = "Hola, recuerda tu evento: " + reminder.getMessage()            
                            + "\nFecha del evento: " + reminder.getShippingDate();


            try {
                EmailSender.sendEmail(email, subject, body);
                dao.markAsSent(reminder.getId());
                System.out.println("📧 Recordatorio enviado a: " + email);
            } catch (Exception e) {
                System.err.println("❌ Error enviando recordatorio a " + email + ": " + e.getMessage());
            }
        }
    }
}
