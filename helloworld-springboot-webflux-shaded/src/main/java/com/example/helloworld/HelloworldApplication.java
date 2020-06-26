package com.example.helloworld;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationListener;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import reactor.core.publisher.Mono;

@SpringBootApplication
public class HelloworldApplication {

  public static void main(String[] args) {
    SpringApplication.run(HelloworldApplication.class, args);
  }
}

@RestController
class HelloController {

  @GetMapping("/")
  Mono<String> hello() {
    return Mono.just("Hello World!");
  }
}
