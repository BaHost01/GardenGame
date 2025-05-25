rootProject.name = "GardenApp" include(":app")

plugins { kotlin("jvm") version "1.8.0" apply false id("com.android.application") version "8.1.0" apply false }

plugins { id("com.android.application") kotlin("android") kotlin("kapt") }

android { compileSdk = 34 defaultConfig { applicationId = "com.cleasantosinc.gardenapp" minSdk = 26 targetSdk = 34 versionCode = 1 versionName = "1.0" } buildFeatures { compose = true } composeOptions { kotlinCompilerExtensionVersion = "1.4.8" } kotlinOptions { jvmTarget = "1.8" } }

dependencies { implementation("androidx.core:core-ktx:1.10.1") implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.1") implementation("androidx.activity:activity-compose:1.7.2") implementation("androidx.compose.ui:ui:1.4.3") implementation("androidx.compose.material:material:1.4.3") implementation("androidx.room:room-runtime:2.5.2") kapt("androidx.room:room-compiler:2.5.2") implementation("androidx.room:room-ktx:2.5.2") implementation("com.squareup.retrofit2:retrofit:2.9.0") implementation("com.squareup.retrofit2:converter-moshi:2.9.0") implementation("com.squareup.moshi:moshi-kotlin:1.14.0") implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4") }

package com.cleasantosinc.gardenapp.data.models

data class Plant( val id: Long, val gardenId: Long, val speciesId: Int, val growthStage: Int, val plantedAt: String, val lastWatered: String? )

package com.cleasantosinc.gardenapp.data.local.entities

import androidx.room.Entity import androidx.room.PrimaryKey

@Entity(tableName = "plants") data class PlantEntity( @PrimaryKey val id: Long, val gardenId: Long, val speciesId: Int, val growthStage: Int, val plantedAt: Long, val lastWatered: Long? )

package com.cleasantosinc.gardenapp.data.local.dao

import androidx.room.* import com.cleasantosinc.gardenapp.data.local.entities.PlantEntity

@Dao interface PlantDao { @Query("SELECT * FROM plants WHERE gardenId = :gardenId") suspend fun getPlants(gardenId: Long): List<PlantEntity> @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun insertPlants(plants: List<PlantEntity>) @Update suspend fun updatePlant(plant: PlantEntity) @Delete suspend fun deletePlant(plant: PlantEntity) }

package com.cleasantosinc.gardenapp.data.local

import androidx.room.Database import androidx.room.RoomDatabase import com.cleasantosinc.gardenapp.data.local.dao.PlantDao import com.cleasantosinc.gardenapp.data.local.entities.PlantEntity

@Database(entities = [PlantEntity::class], version = 1) abstract class AppDatabase : RoomDatabase() { abstract fun plantDao(): PlantDao }

package com.cleasantosinc.gardenapp.data.remote

import com.cleasantosinc.gardenapp.data.models.Plant import retrofit2.http.*

interface ApiService { @GET("/api/gardens/{id}/plants") suspend fun fetchPlants(@Path("id") gardenId: Long): List<Plant> @POST("/api/garden/{id}/plant") suspend fun plantSeed(@Path("id") gardenId: Long, @Body payload: Map<String, Any>): Plant @PUT("/api/plant/{id}") suspend fun updatePlant(@Path("id") plantId: Long, @Body payload: Map<String, Any>): Plant @DELETE("/api/plant/{id}") suspend fun deletePlant(@Path("id") plantId: Long) }

package com.cleasantosinc.gardenapp.data.repository

import com.cleasantosinc.gardenapp.data.local.dao.PlantDao import com.cleasantosinc.gardenapp.data.local.entities.PlantEntity import com.cleasantosinc.gardenapp.data.models.Plant import com.cleasantosinc.gardenapp.data.remote.ApiService import kotlinx.coroutines.Dispatchers import kotlinx.coroutines.withContext

class GardenRepository( private val api: ApiService, private val dao: PlantDao ) { suspend fun getPlants(gardenId: Long): List<Plant> = withContext(Dispatchers.IO) { val local = dao.getPlants(gardenId) if (local.isNotEmpty()) local.map { it.toModel() } else fetchAndCache(gardenId) } private suspend fun fetchAndCache(gardenId: Long): List<Plant> { val remote = api.fetchPlants(gardenId) dao.insertPlants(remote.map { it.toEntity() }) return remote } suspend fun plantSeed(gardenId: Long, speciesId: Int): Plant = withContext(Dispatchers.IO) { val plant = api.plantSeed(gardenId, mapOf("speciesId" to speciesId)) dao.insertPlants(listOf(plant.toEntity())) plant } suspend fun updatePlant(plant: Plant) = withContext(Dispatchers.IO) { val updated = api.updatePlant(plant.id, mapOf("growthStage" to plant.growthStage, "lastWatered" to plant.lastWatered)) dao.updatePlant(updated.toEntity()) } suspend fun deletePlant(plantId: Long) = withContext(Dispatchers.IO) { api.deletePlant(plantId) dao.deletePlant(PlantEntity(plantId,0,0,0,0,null)) } }

package com.cleasantosinc.gardenapp.data

import com.cleasantosinc.gardenapp.data.local.entities.PlantEntity import com.cleasantosinc.gardenapp.data.models.Plant import java.time.Instant

fun PlantEntity.toModel() = Plant( id = id, gardenId = gardenId, speciesId = speciesId, growthStage = growthStage, plantedAt = Instant.ofEpochMilli(plantedAt).toString(), lastWatered = lastWatered?.let { Instant.ofEpochMilli(it).toString() } ) fun Plant.toEntity() = PlantEntity( id = id, gardenId = gardenId, speciesId = speciesId, growthStage = growthStage, plantedAt = Instant.parse(plantedAt).toEpochMilli(), lastWatered = lastWatered?.let { Instant.parse(it).toEpochMilli() } )

package com.cleasantosinc.gardenapp.sync

import com.cleasantosinc.gardenapp.data.repository.GardenRepository import kotlinx.coroutines.*

class SyncManager( private val repository: GardenRepository ) { private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob()) fun startAutoSync(gardenId: Long, intervalMs: Long = 5000L){ scope.launch { while(isActive){ repository.getPlants(gardenId); delay(intervalMs) } } } fun stop(){ scope.cancel() } }

package com.cleasantosinc.gardenapp.ui

import androidx.compose.foundation.background import androidx.compose.foundation.clickable import androidx.compose.foundation.layout.* import androidx.compose.foundation.lazy.grid.GridCells import androidx.compose.foundation.lazy.grid.LazyVerticalGrid import androidx.compose.material.Card import androidx.compose.material.Text import androidx.compose.runtime.* import androidx.compose.ui.Alignment import androidx.compose.ui.Modifier import androidx.compose.ui.unit.dp

@Composable fun IsometricGridScreen(plants: List<Long>, onTileClick: (Long) -> Unit){ LazyVerticalGrid(columns = GridCells.Fixed(5), modifier = Modifier.fillMaxSize()){ items(plants.size){ index -> Card(modifier=Modifier.padding(4.dp).size(60.dp).clickable { onTileClick(plants[index]) }){ Box(contentAlignment = Alignment.Center, modifier = Modifier.background(androidx.compose.ui.graphics.Color.Green)){ Text(text = plants[index].toString()) } }} } }

package com.cleasantosinc.gardenapp.ui

import android.os.Bundle import androidx.activity.ComponentActivity import androidx.activity.compose.setContent import androidx.lifecycle.lifecycleScope import com.cleasantosinc.gardenapp.data.local.AppDatabase import com.cleasantosinc.gardenapp.data.remote.ApiService import com.cleasantosinc.gardenapp.data.repository.GardenRepository import com.cleasantosinc.gardenapp.sync.SyncManager import retrofit2.Retrofit import retrofit2.converter.moshi.MoshiConverterFactory import kotlinx.coroutines.launch

class MainActivity : ComponentActivity(){ private val api by lazy { Retrofit.Builder().baseUrl("https://rrq-n.h.filess.io:3307").addConverterFactory(MoshiConverterFactory.create()).build().create(ApiService::class.java) } private val db by lazy { AppDatabase.getInstance(this) } private val repo by lazy { GardenRepository(api, db.plantDao()) } private val sync by lazy { SyncManager(repo) } override fun onCreate(savedInstanceState: Bundle?){ super.onCreate(savedInstanceState) setContent { var plants by remember { mutableStateOf(listOf<Long>()) } IsometricGridScreen(plants){ } lifecycleScope.launch { plants = repo.getPlants(1).map { it.id } } sync.startAutoSync(1) } } override fun onDestroy(){ super.onDestroy(); sync.stop() } }
