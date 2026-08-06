import bcrypt from "bcryptjs";
import { prisma } from "../database.js";

async function seed() {
  const categories = [
    { slug: "fashion", nameAr: "الأزياء", nameEn: "Fashion", order: 1 },
    { slug: "interior", nameAr: "الديكور الداخلي", nameEn: "Interior Design", order: 2 },
    { slug: "furniture", nameAr: "الأثاث", nameEn: "Furniture", order: 3 },
    { slug: "accessories", nameAr: "الإكسسوارات", nameEn: "Accessories", order: 4 }
  ];
  for (const category of categories) await prisma.category.upsert({ where: { slug: category.slug }, create: category, update: category });
  const demoDesigner = await prisma.user.upsert({
    where: { firebaseUid: "amberdesign-demo-designer" },
    create: { firebaseUid: "amberdesign-demo-designer", displayName: "مصمم أمبرديزاين", role: "designer", verified: true, bio: "حساب تجريبي لعرض منتجات المنصة" },
    update: { displayName: "مصمم أمبرديزاين", role: "designer", verified: true }
  });
  const categoryRows = await prisma.category.findMany({ where: { slug: { in: categories.map(category => category.slug) } } });
  const demos = [
    { id: "10000000-0000-4000-8000-000000000001", slug: "fashion", titleAr: "فستان سهرة أنيق", titleEn: "Elegant Evening Dress", priceHalalas: 85000 },
    { id: "10000000-0000-4000-8000-000000000002", slug: "interior", titleAr: "تصميم مجلس عصري", titleEn: "Modern Majlis Design", priceHalalas: 150000 },
    { id: "10000000-0000-4000-8000-000000000003", slug: "furniture", titleAr: "كرسي بتصميم فاخر", titleEn: "Luxury Designer Chair", priceHalalas: 42000 },
    { id: "10000000-0000-4000-8000-000000000004", slug: "accessories", titleAr: "حقيبة بتفاصيل يدوية", titleEn: "Handcrafted Bag", priceHalalas: 32000 }
  ];
  for (const demo of demos) {
    const category = categoryRows.find(row => row.slug === demo.slug)!;
    await prisma.catalogItem.upsert({
      where: { id: demo.id },
      create: {
        id: demo.id, ownerId: demoDesigner.id, categoryId: category.id, type: "product",
        titleAr: demo.titleAr, titleEn: demo.titleEn,
        descriptionAr: "منتج تجريبي لاختبار البحث والتصنيفات في التطبيق.",
        descriptionEn: "Demo item for testing search and categories.",
        priceHalalas: demo.priceHalalas, images: ["https://placehold.co/600x800/png?text=AmberDesign"],
        stock: 10, active: true, moderationStatus: "approved"
      },
      update: { categoryId: category.id, titleAr: demo.titleAr, titleEn: demo.titleEn, priceHalalas: demo.priceHalalas, active: true, moderationStatus: "approved", stock: 10 }
    });
  }
  if (process.env.SEED_ADMIN_EMAIL && process.env.SEED_ADMIN_PASSWORD) {
    await prisma.user.upsert({ where: { email: process.env.SEED_ADMIN_EMAIL.toLowerCase() }, create: { email: process.env.SEED_ADMIN_EMAIL.toLowerCase(), passwordHash: await bcrypt.hash(process.env.SEED_ADMIN_PASSWORD, 12), displayName: "AmberDesign Admin", role: "admin", verified: true }, update: {} });
  }
  await prisma.page.upsert({ where: { slug: "about" }, create: { slug: "about", titleAr: "عن أمبرديزاين", titleEn: "About AmberDesign", contentAr: "منصة تربط العملاء بالمصممين والمتاجر.", contentEn: "A platform connecting customers, designers, and stores.", published: true }, update: {} });
}

seed()
  .then(() => console.log("Seed complete"))
  .catch(error => {
    console.error("Seed failed", error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
