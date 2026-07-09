<#if (w.getGElementsOfType("biome")?filter(e -> e.spawnBiome || e.spawnInCaves || e.spawnBiomeNether)?size != 0) || w.hasElementsOfType("endbiome")>
public net.minecraft.world.level.levelgen.SurfaceRules$SequenceRuleSource
public net.minecraft.world.level.levelgen.SurfaceRules$SequenceRuleSource <init>(Ljava/util/List;)V
public net.minecraft.world.level.biome.MultiNoiseBiomeSourceParameterList$Preset$SourceProvider
public-f net.minecraft.world.level.levelgen.NoiseBasedChunkGenerator settings
</#if>


<#if w.getGElementsOfType("biome")?filter(e -> e.hasVines() || e.hasFruits())?size != 0>
public net.minecraft.world.level.levelgen.feature.treedecorators.TreeDecoratorType <init>(Lcom/mojang/serialization/MapCodec;)V
</#if>

<#if w.hasElementsOfType("feature")>
public net.minecraft.world.level.levelgen.feature.ScatteredOreFeature <init>(Lcom/mojang/serialization/Codec;)V
public-f net.minecraft.world.level.levelgen.feature.TreeFeature place(Lnet/minecraft/world/level/levelgen/feature/FeaturePlaceContext;)Z
</#if>

# Start of user code block custom ATs
# End of user code block custom ATs