import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.concurrent.Executors;
import java.util.logging.Logger;

public class HelloWorldServer {
  private static final long initialTimestampMs = System.currentTimeMillis();
  private static final Logger logger = Logger.getLogger(HelloWorldServer.class.getName());

  public static void main(String[] args) throws IOException {
    var port = Integer.valueOf(Optional.ofNullable(System.getenv("PORT")).orElse("8080"));

    var server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0);
    server.setExecutor(
        Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors() * 2));

    server.createContext(
        "/",
        exchange -> {
          var response = "Hello World!".getBytes(StandardCharsets.UTF_8);
          exchange.sendResponseHeaders(200, response.length);
          exchange.getResponseBody().write(response);
          exchange.close();
        });

    Runtime.getRuntime().addShutdownHook(new Thread(() -> server.stop(0)));

    final var readyTimestampMs = System.currentTimeMillis();

    logger.info("Started: " + (readyTimestampMs - initialTimestampMs) + "ms");
    server.start();

    if ("true".equalsIgnoreCase(System.getenv("EXIT_IMMEDIATELY"))) {
      System.exit(0);
    }
  }
}
