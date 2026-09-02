package bron.mobile.uz.bron_mobile

import android.app.Application
import com.yandex.mapkit.MapKitFactory

/**
 * Yandex MapKit Android'da AndroidManifest meta-data'dan emas, faqat
 * `MapKitFactory.setApiKey(...)` dasturiy chaqiruvidan kalitni o'qiydi —
 * bu chaqiruv `Application.onCreate()`da, har qanday xarita view'i
 * yaratilishidan OLDIN bo'lishi shart (rasmiy namuna: yandex_mapkit
 * paketi, example/android/.../MainApplication.java). Shu klass yo'qligi
 * "androidda xarita ekrani ishlamaydi" muammosining sababi edi.
 */
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setApiKey("b087e69a-96e9-4ecc-a404-0f30278dc140")
    }
}
