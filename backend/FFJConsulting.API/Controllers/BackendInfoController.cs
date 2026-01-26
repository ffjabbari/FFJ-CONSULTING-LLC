using Microsoft.AspNetCore.Mvc;

namespace FFJConsulting.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BackendInfoController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public BackendInfoController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public IActionResult GetBackendInfo()
    {
        var backendName = _configuration["Backend:Name"] ?? "C#";
        var backendVersion = _configuration["Backend:Version"] ?? "8.0";

        return Ok(new
        {
            backend = backendName,
            version = backendVersion,
            message = $"Hello from {backendName} backend!",
            timestamp = DateTime.UtcNow
        });
    }
}
