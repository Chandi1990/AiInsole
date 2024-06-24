FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["AiInsole/AiInsole.csproj", "AiInsole/"]
RUN dotnet restore "./AiInsole/AiInsole.csproj"
COPY . .
WORKDIR "/src/AiInsole"
RUN dotnet build "./AiInsole.csproj" -c $BUILD_CONFIGURATION -o "/var/www/public_html/build"

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./AiInsole.csproj" -c $BUILD_CONFIGURATION -o "/var/www/public_html" /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /var/www/public_html .
ENTRYPOINT ["dotnet", "AiInsole.dll"]