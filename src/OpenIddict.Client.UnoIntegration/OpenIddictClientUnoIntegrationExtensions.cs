/*
 * Licensed under the Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
 * See https://github.com/openiddict/openiddict-core for more information concerning
 * the license and the contributors participating to this project.
 */

using System.Runtime.InteropServices;

using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

using OpenIddict.Client;
using OpenIddict.Client.SystemIntegration;
using OpenIddict.Client.UnoIntegration;

namespace Microsoft.Extensions.DependencyInjection;

/// <summary>
/// Exposes extensions allowing to register the OpenIddict client services.
/// </summary>
public static class OpenIddictClientUnoIntegrationExtensions
{
    /// <summary>
    /// Adds handling of protocol activation
    /// </summary>
    /// <param name="builder"></param>
    /// <param name="configureDelegate"></param>
    public static async Task<IApplicationBuilder> UseOpenIddictClientActivationHandlingAsync(this IApplicationBuilder builder, Action<IServiceCollection> configureDelegate)
    {
        var host = new Microsoft.Extensions.Hosting.HostBuilder()
            .ConfigureServices(services =>
            {
                configureDelegate(services);
                services.AddSingleton<IHostApplicationLifetime, ActivationHostApplicationLifetime>();
            })
            .Build();
        await host.RunAsync();
        host.Dispose();

        return builder.Configure(host => host.ConfigureServices(configureDelegate));
    }

    /// <summary>
    /// Registers the OpenIddict client system integration services in the DI container.
    /// </summary>
    /// <param name="builder">The services builder used by OpenIddict to register new services.</param>
    /// <remarks>This extension can be safely called multiple times.</remarks>
    /// <returns>The <see cref="OpenIddictClientSystemIntegrationBuilder"/>.</returns>
    public static OpenIddictClientSystemIntegrationBuilder UseUnoIntegration(this OpenIddictClientBuilder builder)
    {
        var systemBuilder = builder.UseSystemIntegration();
        builder.Services.AddSingleton<IHostApplicationLifetime, UnoHostApplicationLifetime>();
        return new OpenIddictClientSystemIntegrationBuilder(builder.Services);
    }

    /// <summary>
    /// Registers the OpenIddict client system integration services in the DI container.
    /// </summary>
    /// <param name="builder">The services builder used by OpenIddict to register new services.</param>
    /// <param name="configuration">The configuration delegate used to configure the client services.</param>
    /// <remarks>This extension can be safely called multiple times.</remarks>
    /// <returns>The <see cref="OpenIddictClientBuilder"/>.</returns>
    public static OpenIddictClientBuilder UseUnoIntegration(
        this OpenIddictClientBuilder builder, Action<OpenIddictClientSystemIntegrationBuilder> configuration)
    {
        builder.UseSystemIntegration(configuration);
        builder.Services.AddSingleton<IHostApplicationLifetime, UnoHostApplicationLifetime>();
        return builder;
    }
}
