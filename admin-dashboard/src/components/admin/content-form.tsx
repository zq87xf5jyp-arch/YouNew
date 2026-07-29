"use client";

import { useState } from "react";
import { Save } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectGroup, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { slugify } from "@/lib/utils";

export function ContentForm({ title = "Создать материал" }: { title?: string }) {
  const [name, setName] = useState("");
  const [slug, setSlug] = useState("");

  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
        <CardDescription>Форма для контента приложения: источник, категория, статус публикации и теги.</CardDescription>
      </CardHeader>
      <CardContent>
        <form className="grid gap-4 lg:grid-cols-2">
          <div className="flex flex-col gap-2">
            <Label htmlFor="title">Название</Label>
            <Input
              id="title"
              value={name}
              onChange={(event) => {
                setName(event.target.value);
                setSlug(slugify(event.target.value));
              }}
              placeholder="Регистрация в муниципалитете"
            />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="slug">Слаг</Label>
            <Input id="slug" value={slug} onChange={(event) => setSlug(event.target.value)} />
          </div>
          <div className="flex flex-col gap-2">
            <Label>Категория</Label>
            <Select defaultValue="documents-services">
              <SelectTrigger>
                <SelectValue placeholder="Выберите категорию" />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  <SelectItem value="documents-services">Документы и сервисы</SelectItem>
                  <SelectItem value="transport">Транспорт</SelectItem>
                  <SelectItem value="housing">Жилье</SelectItem>
                  <SelectItem value="healthcare">Здравоохранение</SelectItem>
                </SelectGroup>
              </SelectContent>
            </Select>
          </div>
          <div className="flex flex-col gap-2">
            <Label>Статус</Label>
            <Select defaultValue="draft">
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  <SelectItem value="draft">Черновик</SelectItem>
                  <SelectItem value="review">На проверке</SelectItem>
                  <SelectItem value="published">Опубликовано</SelectItem>
                  <SelectItem value="archived">Архив</SelectItem>
                </SelectGroup>
              </SelectContent>
            </Select>
          </div>
          <div className="flex flex-col gap-2 lg:col-span-2">
            <Label htmlFor="description">Короткое описание</Label>
            <Input id="description" placeholder="Понятное резюме для новичков." />
          </div>
          <div className="flex flex-col gap-2 lg:col-span-2">
            <Label htmlFor="content">Полный текст</Label>
            <Textarea id="content" placeholder="Напишите или вставьте текст гайда..." />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="source">Официальный источник URL</Label>
            <Input id="source" placeholder="https://www.government.nl/..." />
          </div>
          <div className="flex flex-col gap-2">
            <Label htmlFor="tags">Теги</Label>
            <Input id="tags" placeholder="bsn, municipality, registration" />
          </div>
          <div className="lg:col-span-2">
            <Button type="button">
              <Save data-icon="inline-start" />
              Сохранить черновик
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
