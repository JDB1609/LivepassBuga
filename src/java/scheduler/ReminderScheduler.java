/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package scheduler;

import java.util.Timer;
import java.util.TimerTask;
import servicio.RecordatorioServicio;

public class ReminderScheduler {
    private Timer timer;

    public void start() {
        timer = new Timer(true); // hilo en background
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                try {
                    RecordatorioServicio service = new RecordatorioServicio();
                    service.checkAndSendReminders();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }, 0, 60 * 60 * 1000); // cada hora
    }

    public void stop() {
        if (timer != null) {
            timer.cancel();
        }
    }

}
