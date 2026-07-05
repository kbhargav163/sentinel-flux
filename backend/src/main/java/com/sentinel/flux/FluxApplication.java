package com.sentinel.flux;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.CrossOrigin;

import java.util.Map;
import java.util.Random;

@SpringBootApplication
public class FluxApplication {
    public static void main(String[] args) {
        SpringApplication.run(FluxApplication.class, args);
    }
}

@RestController
@CrossOrigin(origins = "*")
class MetricsTargetController {
    private final Random random = new Random();

    @GetMapping("/api/v1/checkout")
    public Map<String, String> executeCheckout() {
        // Simulate minor variable processing network delay cycles
        try {
            Thread.sleep(random.nextInt(150));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Randomly simulate server failures to generate real metrics data
        if (random.nextInt(10) == 7) {
            throw new RuntimeException("Payment processing network timeout");
        }
        
        return Map.of("status", "SUCCESS", "message", "Transaction completed successfully");
    }

    @GetMapping("/api/v1/availability")
    public Map<String, Object> checkSystemAvailability() {
        return Map.of("uptime", "UP", "service", "sentinel-flux-core", "sla_target", 99.9);
    }
}