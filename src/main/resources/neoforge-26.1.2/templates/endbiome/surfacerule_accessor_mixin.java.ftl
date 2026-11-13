package ${package}.mixin;

import org.spongepowered.asm.mixin.Mutable;

/** Lets the generated SurfaceRules class add surface rules for its end biomes. */
@Mixin(NoiseGeneratorSettings.class)
public interface NoiseGeneratorSettingsAccess {

	@Accessor("surfaceRule")
	@Mutable
	void addSurfaceRule(SurfaceRules.RuleSource ruleSource);

}