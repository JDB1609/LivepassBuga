/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package scheduler;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class InitScheduler implements ServletContextListener{

    private ReminderScheduler scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = new ReminderScheduler();
        try {
            scheduler.start();
            System.out.println("✅ ReminderScheduler iniciado correctamente.");
        } catch (Exception e) {
            System.err.println("❌ Error iniciando ReminderScheduler: " + e.getMessage());
        }

    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.stop();
            System.out.println("🛑 ReminderScheduler detenido correctamente.");
        }
    }    
}
