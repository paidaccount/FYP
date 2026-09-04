class ApiEndpoints {
  static const String baseUrl = "http://localhost:8000/api/v1";

  // Auth Endpoints
  static const String register = "/auth/register";
  static const String login = "/auth/login";

  // Vehicles Endpoints
  static const String vehicles = "/vehicles";

  // Predictions & XAI Endpoints
  static const String checkTelemetry = "/predictions/check";
  static const String getExplanation = "/predictions"; // Append: /{id}/explanation

  // Trust Endpoints
  static const String trustScore = "/trust"; // Append: /{id}/score

  // Emergency Priority Endpoints
  static const String authorizeEmergency = "/emergency/authorize";
  static const String requestPriority = "/emergency/request-priority";

  // Routes Endpoints
  static const String routes = "/routes";

  // Reports Endpoints
  static const String reports = "/reports";

  // Notifications Endpoints
  static const String registerToken = "/notifications/register-token";

  // Analytics Endpoints
  static const String overview = "/analytics/overview";
}
