package com.sensitive;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.autoconfigure.DataSourceAutoConfiguration;

/**
 * 启动程序
 *
 * @author sensitive
 */
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
public class SensitiveApplication {
    public static void main(String[] args) {
        // System.setProperty("spring.devtools.restart.enabled", "false");
        SpringApplication.run(SensitiveApplication.class, args);
        System.out.println("""
                 /\\ _ /\\
                ( • ◡ • )    sensitive启动成功
                / >✨< \\
                |       |
                |_______|
                """);
    }
}
