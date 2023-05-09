FROM gradle:7.5.1-jdk17-alpine AS build

WORKDIR /data
COPY . /data

RUN apk update && apk add curl unzip && \
  curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && \
  unzip -q newrelic-java.zip

RUN gradle assemble --no-daemon

FROM openjdk:17.0.2-slim-buster

ARG APP_VERSION=latest

ENV APP_VERSION=$APP_VERSION \
    APP_PATH=/build/libs/<app-name>-0.0.1-SNAPSHOT.jar

RUN groupadd -r kotlin && \
  useradd -r -g kotlin kotlin

COPY --chown=kotlin:kotlin --from=build /data/newrelic/newrelic.* /opt/newrelic/
COPY --chown=kotlin:kotlin --from=build /data/${APP_PATH} /opt/app/app.jar

USER kotlin
EXPOSE 8080




CMD ["java", "-javaagent:/opt/newrelic/newrelic.jar", "-jar", "/opt/app/app.jar"]