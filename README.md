# Dynamic Proxying with Nginx and LaunchDarkly

This repository provides a sample configuration for using Nginx with [LaunchDarkly](https://launchdarkly.com). It demonstrates how to dynamically change the `proxy_pass` directive in Nginx based on a LaunchDarkly flag of type `String`. The setup is based on the [LaunchDarkly Nginx guide](https://docs.launchdarkly.com/guides/sdk/nginx) and the [LaunchDarkly Lua SDK repository](https://github.com/launchdarkly/lua-server-sdk).

## Prerequisites

- A LaunchDarkly account and an SDK key.
- A LaunchDarkly feature flag of type `String` that will be used to determine the `proxy_pass` target.

## Getting Started

### 1. Clone the repository

Clone this repository to your local machine:

```bash
git clone https://github.com/your-username/nginx-with-launchdarkly.git
cd nginx-with-launchdarkly
```

### 2. Build the Docker image

Build the Docker image using the provided `Dockerfile`:

```bash
docker build -t nginx-with-launchdarkly .
```

### 3. Run the Docker container

Run the Docker container with the required environment variables. Make sure to replace `"your-sdk-key"` and `"your-flag-key"` with your actual LaunchDarkly SDK key and flag key.

```bash
docker run --rm -p 8080:80 -e LAUNCHDARKLY_SDK_KEY="your-sdk-key" -e LAUNCHDARKLY_FLAG_KEY="your-flag-key" nginx-with-launchdarkly
```

This command will start Nginx on `localhost:8080`. The `proxy_pass` target will be determined by the value of the specified LaunchDarkly flag.

## How It Works

The configuration uses the LaunchDarkly Lua SDK to fetch the value of a feature flag and dynamically set the `proxy_pass` directive in Nginx. This enables routing requests to different backends based on the flag value.

1. The Lua script initializes the LaunchDarkly client using the provided SDK key.
2. When a request is received, the script checks the specified flag (`LAUNCHDARKLY_FLAG_KEY`) and sets the `proxy_pass` target based on the flag's value.
3. If the flag is not set or an error occurs, a default fallback domain (if specified) can be used.

## Environment Variables

- `LAUNCHDARKLY_SDK_KEY`: Your LaunchDarkly SDK key. This is required for the SDK to communicate with LaunchDarkly.
- `LAUNCHDARKLY_FLAG_KEY`: The key of the LaunchDarkly feature flag used to determine the `proxy_pass` target.
- `FALLBACK_DOMAIN` (optional): A default domain to use if the flag evaluation fails.

## References

- [LaunchDarkly Nginx Guide](https://docs.launchdarkly.com/guides/sdk/nginx)
- [LaunchDarkly Lua SDK Repository](https://github.com/launchdarkly/lua-server-sdk)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
