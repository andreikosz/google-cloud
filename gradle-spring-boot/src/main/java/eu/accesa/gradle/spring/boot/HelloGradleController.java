package eu.accesa.gradle.spring.boot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController("/")
public class HelloGradleController {

    @GetMapping
    public String helloGradle() {
        return "not anymore";
    }

}
