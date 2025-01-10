﻿using System.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Win32;

namespace OpenIddict.Sandbox.UnoClient;

public class Worker : IHostedService
{
    private readonly IServiceProvider _provider;
    private readonly IHostApplicationLifetime _lifetime;

    public Worker(IServiceProvider provider, IHostApplicationLifetime lifetime)

    {
        _provider = provider;
        _lifetime = lifetime;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        using var scope = _provider.CreateScope();

        var context = scope.ServiceProvider.GetRequiredService<DbContext>();
        await context.Database.EnsureCreatedAsync(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
