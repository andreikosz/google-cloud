FROM openjdk:11
ARG artifact
ENV artifact_name ${artifact}
COPY ./build/libs/${artifact} ${artifact}
EXPOSE 8080
ENTRYPOINT ["sh", "-c"]
CMD ["java -jar ${artifact_name}"]