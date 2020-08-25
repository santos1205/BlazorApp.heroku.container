FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /src
COPY ["BlazorApp/BlazorApp.csproj", "BlazorApp/"]
RUN dotnet restore "BlazorApp/BlazorApp.csproj"
COPY ./BlazorApp ./BlazorApp
WORKDIR "/src/BlazorApp"
RUN dotnet build "BlazorApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BlazorApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY ./BlazorApp/wwwroot ./wwwroot

RUN useradd -m myappuser
USER myappuser

CMD ASPNETCORE_URLS="http://*:$PORT" dotnet BlazorApp.dll