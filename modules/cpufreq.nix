{ ... }:
{
	services.auto-cpufreq = {
		enable = true;
		settings = {
			battery = {
				enable_thresholds = true;
				start_threshold = 70;
				stop_threshold = 80;
				energy_performance_preference = "power";
				energy_perf_bias = "power";
				platform_profile = "low-power";
			};
			charger = {
				energy_perf_bias = "performance";
				platform_profile = "performance";
			};
		};
	};
}
